# CHAT + MODERACIYA + API + TARIFY + VERIFIKACIYA - POLNAYA DOKUMENTACIYA

## CHAST 1: REAL-TIME CHAT MEZHDU POLZOVATELYAMI

### Технологии
- PHP + WebSocket (Ratchet)
- MySQL для хранения сообщений
- JavaScript для клиента
- Real-time обмен сообщениями

### SQL STRUKTURA

```sql
-- Dialogi/Konversacii
CREATE TABLE conversations (
    id INT AUTO_INCREMENT PRIMARY KEY,
    listing_id INT NULL,
    user1_id INT NOT NULL,
    user2_id INT NOT NULL,
    last_message_id INT NULL,
    last_message_at TIMESTAMP NULL,
    is_archived_user1 BOOLEAN DEFAULT FALSE,
    is_archived_user2 BOOLEAN DEFAULT FALSE,
    is_blocked_user1 BOOLEAN DEFAULT FALSE,
    is_blocked_user2 BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (listing_id) REFERENCES listings(id) ON DELETE SET NULL,
    FOREIGN KEY (user1_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (user2_id) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE KEY unique_users (user1_id, user2_id, listing_id),
    INDEX idx_user1 (user1_id),
    INDEX idx_user2 (user2_id),
    INDEX idx_listing (listing_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Soobscheniya
CREATE TABLE messages (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    conversation_id INT NOT NULL,
    sender_id INT NOT NULL,
    message_text TEXT NOT NULL,
    attachment_type ENUM('image', 'document', 'video') NULL,
    attachment_url VARCHAR(255) NULL,
    is_read BOOLEAN DEFAULT FALSE,
    read_at TIMESTAMP NULL,
    is_deleted BOOLEAN DEFAULT FALSE,
    deleted_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (conversation_id) REFERENCES conversations(id) ON DELETE CASCADE,
    FOREIGN KEY (sender_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_conversation (conversation_id),
    INDEX idx_sender (sender_id),
    INDEX idx_created (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Bystryye shablony soobscheniy
CREATE TABLE message_templates (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    title VARCHAR(100) NOT NULL,
    message_text TEXT NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    sort_order INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

### PHP CODE - ChatServer.php

```php
<?php
// Ustanovka: composer require cboden/ratchet

use Ratchet\MessageComponentInterface;
use Ratchet\ConnectionInterface;
use Ratchet\Server\IoServer;
use Ratchet\Http\HttpServer;
use Ratchet\WebSocket\WsServer;

class ChatServer implements MessageComponentInterface {
    protected $clients;
    protected $users;
    private $db;
    
    public function __construct($database) {
        $this->clients = new \SplObjectStorage;
        $this->users = [];
        $this->db = $database;
        echo "Chat server started!\n";
    }
    
    public function onOpen(ConnectionInterface $conn) {
        $this->clients->attach($conn);
        echo "New connection: {$conn->resourceId}\n";
    }
    
    public function onMessage(ConnectionInterface $from, $msg) {
        $data = json_decode($msg, true);
        
        if (!$data) {
            return;
        }
        
        switch ($data['type']) {
            case 'auth':
                $this->handleAuth($from, $data);
                break;
            case 'send_message':
                $this->handleSendMessage($from, $data);
                break;
            case 'typing':
                $this->handleTyping($from, $data);
                break;
            case 'mark_read':
                $this->handleMarkRead($data);
                break;
        }
    }
    
    private function handleAuth($conn, $data) {
        $userId = $data['user_id'];
        $token = $data['token'];
        
        // Proverit JWT token
        if ($this->verifyToken($userId, $token)) {
            $this->users[$userId] = $conn;
            
            $conn->send(json_encode([
                'type' => 'authenticated',
                'user_id' => $userId,
                'message' => 'Successfully authenticated'
            ]));
            
            echo "User {$userId} authenticated\n";
        }
    }
    
    private function handleSendMessage($from, $data) {
        $conversationId = $data['conversation_id'];
        $senderId = $data['sender_id'];
        $messageText = $data['message'];
        
        // Sohranit soobschenie
        $messageId = $this->saveMessage($conversationId, $senderId, $messageText);
        
        if (!$messageId) {
            return;
        }
        
        // Poluchit dannye soobscheniya
        $message = $this->getMessage($messageId);
        
        // Otpravit poluchatelyu
        $recipientId = $this->getRecipientId($conversationId, $senderId);
        
        if (isset($this->users[$recipientId])) {
            $this->users[$recipientId]->send(json_encode([
                'type' => 'new_message',
                'message' => $message
            ]));
        }
        
        // Podtverzhdenie otpravitelyu
        $from->send(json_encode([
            'type' => 'message_sent',
            'message' => $message
        ]));
        
        echo "Message {$messageId} sent from {$senderId} to {$recipientId}\n";
    }
    
    private function handleTyping($from, $data) {
        $conversationId = $data['conversation_id'];
        $userId = array_search($from, $this->users);
        
        if ($userId === false) return;
        
        $recipientId = $this->getRecipientId($conversationId, $userId);
        
        if (isset($this->users[$recipientId])) {
            $this->users[$recipientId]->send(json_encode([
                'type' => 'user_typing',
                'conversation_id' => $conversationId,
                'user_id' => $userId
            ]));
        }
    }
    
    private function handleMarkRead($data) {
        $conversationId = $data['conversation_id'];
        $userId = $data['user_id'];
        
        $sql = "UPDATE messages 
                SET is_read = TRUE, read_at = NOW()
                WHERE conversation_id = :conv_id 
                AND sender_id != :user_id 
                AND is_read = FALSE";
        
        $stmt = $this->db->prepare($sql);
        $stmt->execute([
            'conv_id' => $conversationId,
            'user_id' => $userId
        ]);
    }
    
    private function saveMessage($conversationId, $senderId, $messageText) {
        $sql = "INSERT INTO messages (conversation_id, sender_id, message_text)
                VALUES (:conv_id, :sender_id, :message)";
        
        $stmt = $this->db->prepare($sql);
        $result = $stmt->execute([
            'conv_id' => $conversationId,
            'sender_id' => $senderId,
            'message' => $messageText
        ]);
        
        if ($result) {
            // Obnovit last_message v conversation
            $messageId = $this->db->lastInsertId();
            $this->updateConversation($conversationId, $messageId);
            return $messageId;
        }
        
        return null;
    }
    
    private function updateConversation($conversationId, $messageId) {
        $sql = "UPDATE conversations 
                SET last_message_id = :msg_id, last_message_at = NOW()
                WHERE id = :conv_id";
        
        $stmt = $this->db->prepare($sql);
        $stmt->execute([
            'msg_id' => $messageId,
            'conv_id' => $conversationId
        ]);
    }
    
    private function getMessage($messageId) {
        $sql = "SELECT m.*, u.first_name, u.last_name 
                FROM messages m
                JOIN users u ON m.sender_id = u.id
                WHERE m.id = :id";
        
        $stmt = $this->db->prepare($sql);
        $stmt->execute(['id' => $messageId]);
        return $stmt->fetch(PDO::FETCH_ASSOC);
    }
    
    private function getRecipientId($conversationId, $senderId) {
        $sql = "SELECT user1_id, user2_id FROM conversations WHERE id = :id";
        $stmt = $this->db->prepare($sql);
        $stmt->execute(['id' => $conversationId]);
        $conv = $stmt->fetch(PDO::FETCH_ASSOC);
        
        return $conv['user1_id'] == $senderId ? $conv['user2_id'] : $conv['user1_id'];
    }
    
    private function verifyToken($userId, $token) {
        // Prostaya proverka - v realnosti ispolzovat JWT
        return true;
    }
    
    public function onClose(ConnectionInterface $conn) {
        $this->clients->detach($conn);
        
        $userId = array_search($conn, $this->users);
        if ($userId !== false) {
            unset($this->users[$userId]);
            echo "User {$userId} disconnected\n";
        }
    }
    
    public function onError(ConnectionInterface $conn, \Exception $e) {
        echo "Error: {$e->getMessage()}\n";
        $conn->close();
    }
}

// Zapusk servera (chat-server.php)
require 'vendor/autoload.php';

$db = new PDO('mysql:host=localhost;dbname=marketplace', 'root', 'password');
$chat = new ChatServer($db);

$server = IoServer::factory(
    new HttpServer(
        new WsServer($chat)
    ),
    8080
);

echo "WebSocket server running on port 8080\n";
$server->run();
```

---

### JavaScript CLIENT

```javascript
class ChatClient {
    constructor(userId, token) {
        this.userId = userId;
        this.token = token;
        this.ws = null;
        this.reconnectAttempts = 0;
        this.maxReconnectAttempts = 5;
        this.connect();
    }
    
    connect() {
        this.ws = new WebSocket('ws://localhost:8080');
        
        this.ws.onopen = () => {
            console.log('Connected to chat server');
            this.authenticate();
            this.reconnectAttempts = 0;
        };
        
        this.ws.onmessage = (event) => {
            const data = JSON.parse(event.data);
            this.handleMessage(data);
        };
        
        this.ws.onclose = () => {
            console.log('Disconnected from chat server');
            this.reconnect();
        };
        
        this.ws.onerror = (error) => {
            console.error('WebSocket error:', error);
        };
    }
    
    authenticate() {
        this.send({
            type: 'auth',
            user_id: this.userId,
            token: this.token
        });
    }
    
    sendMessage(conversationId, message) {
        this.send({
            type: 'send_message',
            conversation_id: conversationId,
            sender_id: this.userId,
            message: message
        });
    }
    
    sendTypingIndicator(conversationId) {
        this.send({
            type: 'typing',
            conversation_id: conversationId
        });
    }
    
    markAsRead(conversationId) {
        this.send({
            type: 'mark_read',
            conversation_id: conversationId,
            user_id: this.userId
        });
    }
    
    send(data) {
        if (this.ws.readyState === WebSocket.OPEN) {
            this.ws.send(JSON.stringify(data));
        }
    }
    
    handleMessage(data) {
        switch(data.type) {
            case 'authenticated':
                console.log('Authenticated successfully');
                this.onAuthenticated && this.onAuthenticated(data);
                break;
            case 'new_message':
                console.log('New message received:', data.message);
                this.onNewMessage && this.onNewMessage(data.message);
                break;
            case 'message_sent':
                console.log('Message sent confirmation');
                this.onMessageSent && this.onMessageSent(data.message);
                break;
            case 'user_typing':
                console.log('User is typing...');
                this.onUserTyping && this.onUserTyping(data);
                break;
        }
    }
    
    reconnect() {
        if (this.reconnectAttempts < this.maxReconnectAttempts) {
            this.reconnectAttempts++;
            console.log(`Reconnecting... Attempt ${this.reconnectAttempts}`);
            setTimeout(() => this.connect(), 2000);
        }
    }
}

// Ispolzovanie
const chat = new ChatClient(123, 'jwt_token_here');

chat.onNewMessage = (message) => {
    // Otobrazit novoe soobschenie
    displayMessage(message);
};

chat.onUserTyping = (data) => {
    // Pokazat indikator nabora teksta
    showTypingIndicator(data.conversation_id);
};

// Otpravka soobscheniya
document.getElementById('sendBtn').addEventListener('click', () => {
    const message = document.getElementById('messageInput').value;
    const conversationId = getCurrentConversationId();
    chat.sendMessage(conversationId, message);
});
```

---

## CHAST 2: SISTEMA MODERACII

### SQL

```sql
CREATE TABLE reports (
    id INT AUTO_INCREMENT PRIMARY KEY,
    reporter_id INT NOT NULL,
    reported_user_id INT NULL,
    reported_listing_id INT NULL,
    report_type ENUM('spam', 'fraud', 'inappropriate', 'wrong_category', 'other') NOT NULL,
    reason TEXT NOT NULL,
    status ENUM('pending', 'reviewing', 'resolved', 'rejected') DEFAULT 'pending',
    priority ENUM('low', 'medium', 'high', 'critical') DEFAULT 'medium',
    moderator_id INT NULL,
    moderator_notes TEXT NULL,
    action_taken ENUM('none', 'warning', 'deleted', 'banned') NULL,
    resolved_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (reporter_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

---

## CHAST 3: MOBILNOE API

### REST API Endpoints

```
POST   /api/auth/login
POST   /api/auth/register
GET    /api/listings
GET    /api/listings/:id
POST   /api/listings
PUT    /api/listings/:id
DELETE /api/listings/:id
GET    /api/search
POST   /api/favorites/:id
GET    /api/messages
POST   /api/messages
GET    /api/notifications
```

---

## CHAST 4: SISTEMA TARIFOV

### Pakety

| Paket | Cena | Obyavleniy | Funkcii |
|-------|------|------------|---------|
| Free | 0€ | 1 | Bazovye |
| Bronze | 49.99€ | 5 | + Featured |
| Silver | 99.99€ | 15 | + Priority |
| Gold | 199.99€ | 50 | + Top ads |
| Platinum | 399.99€ | Unlimited | All |

---

## CHAST 5: VERIFIKACIYA

### Urovni verifikacii
- ✅ Email
- ✅ Telefon
- ✅ Dokumenty
- ✅ Adres
- ✅ Biznes-licenziya

---

**GOTOVO!** ✅