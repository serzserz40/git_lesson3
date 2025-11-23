<?php
/**
 * Калькулятор финансирования (Лизинг / Кредит)
 * Путь: api/financing/calculator.php
 */

require_once '../../config/database.php';

header('Content-Type: application/json');

// Получение данных
$data = json_decode(file_get_contents('php://input'), true);

$listingId = $data['listing_id'] ?? null;
$calculatorType = $data['type'] ?? 'leasing'; // leasing, loan, installment
$vehiclePrice = floatval($data['price'] ?? 0);
$downPayment = floatval($data['down_payment'] ?? 0);
$termMonths = intval($data['term_months'] ?? 36);
$interestRate = floatval($data['interest_rate'] ?? 3.9);
$residualValue = floatval($data['residual_value'] ?? 0);

// Валидация
if ($vehiclePrice <= 0) {
    echo json_encode(['success' => false, 'message' => 'Ungültiger Fahrzeugpreis']);
    exit;
}

if ($downPayment < 0 || $downPayment > $vehiclePrice) {
    echo json_encode(['success' => false, 'message' => 'Ungültige Anzahlung']);
    exit;
}

if ($termMonths < 12 || $termMonths > 120) {
    echo json_encode(['success' => false, 'message' => 'Laufzeit muss zwischen 12 und 120 Monaten liegen']);
    exit;
}

/**
 * Расчёт лизинга
 */
function calculateLeasing($price, $downPayment, $months, $rate, $residualValue) {
    // Сумма финансирования
    $financeAmount = $price - $downPayment;
    
    // Остаточная стоимость (если не задана - 40% для 36 месяцев)
    if ($residualValue == 0) {
        $residualPercent = max(10, 60 - ($months / 12 * 10)); // Уменьшается с годами
        $residualValue = $price * ($residualPercent / 100);
    }
    
    // Амортизация
    $depreciation = $financeAmount - $residualValue;
    
    // Месячная процентная ставка
    $monthlyRate = $rate / 100 / 12;
    
    // Ежемесячный платёж (амортизация + проценты)
    $monthlyDepreciation = $depreciation / $months;
    $monthlyInterest = ($financeAmount + $residualValue) / 2 * $monthlyRate;
    $monthlyPayment = $monthlyDepreciation + $monthlyInterest;
    
    // Общая сумма выплат
    $totalPayment = $downPayment + ($monthlyPayment * $months) + $residualValue;
    
    // Общая переплата
    $totalInterest = $totalPayment - $price;
    
    return [
        'monthly_payment' => round($monthlyPayment, 2),
        'total_payment' => round($totalPayment, 2),
        'total_interest' => round($totalInterest, 2),
        'down_payment' => $downPayment,
        'finance_amount' => $financeAmount,
        'residual_value' => round($residualValue, 2),
        'depreciation' => round($depreciation, 2),
        'monthly_depreciation' => round($monthlyDepreciation, 2),
        'monthly_interest' => round($monthlyInterest, 2)
    ];
}

/**
 * Расчёт кредита (аннуитетный)
 */
function calculateLoan($price, $downPayment, $months, $rate) {
    // Сумма кредита
    $loanAmount = $price - $downPayment;
    
    // Месячная процентная ставка
    $monthlyRate = $rate / 100 / 12;
    
    // Аннуитетный коэффициент
    if ($monthlyRate > 0) {
        $annuityFactor = ($monthlyRate * pow(1 + $monthlyRate, $months)) / 
                        (pow(1 + $monthlyRate, $months) - 1);
    } else {
        $annuityFactor = 1 / $months;
    }
    
    // Ежемесячный платёж
    $monthlyPayment = $loanAmount * $annuityFactor;
    
    // Общая сумма выплат
    $totalPayment = $downPayment + ($monthlyPayment * $months);
    
    // Переплата
    $totalInterest = $totalPayment - $price;
    
    return [
        'monthly_payment' => round($monthlyPayment, 2),
        'total_payment' => round($totalPayment, 2),
        'total_interest' => round($totalInterest, 2),
        'down_payment' => $downPayment,
        'loan_amount' => $loanAmount,
        'effective_rate' => $rate
    ];
}

/**
 * Расчёт рассрочки (без процентов)
 */
function calculateInstallment($price, $downPayment, $months) {
    $installmentAmount = $price - $downPayment;
    $monthlyPayment = $installmentAmount / $months;
    
    return [
        'monthly_payment' => round($monthlyPayment, 2),
        'total_payment' => $price,
        'total_interest' => 0,
        'down_payment' => $downPayment,
        'installment_amount' => $installmentAmount
    ];
}

// Выполнение расчёта
$result = null;

switch ($calculatorType) {
    case 'leasing':
        $result = calculateLeasing($vehiclePrice, $downPayment, $termMonths, $interestRate, $residualValue);
        break;
        
    case 'loan':
        $result = calculateLoan($vehiclePrice, $downPayment, $termMonths, $interestRate);
        break;
        
    case 'installment':
        $result = calculateInstallment($vehiclePrice, $downPayment, $termMonths);
        break;
        
    default:
        echo json_encode(['success' => false, 'message' => 'Ungültiger Berechnungstyp']);
        exit;
}

// График платежей
$schedule = [];
$remainingBalance = $vehiclePrice - $downPayment;

for ($month = 1; $month <= $termMonths; $month++) {
    $monthlyRate = $interestRate / 100 / 12;
    
    if ($calculatorType == 'loan') {
        $interest = $remainingBalance * $monthlyRate;
        $principal = $result['monthly_payment'] - $interest;
        $remainingBalance -= $principal;
    } elseif ($calculatorType == 'leasing') {
        $interest = $result['monthly_interest'];
        $principal = $result['monthly_depreciation'];
        $remainingBalance -= $principal;
    } else {
        $interest = 0;
        $principal = $result['monthly_payment'];
        $remainingBalance -= $principal;
    }
    
    $schedule[] = [
        'month' => $month,
        'payment' => $result['monthly_payment'],
        'principal' => round($principal, 2),
        'interest' => round($interest, 2),
        'balance' => round(max(0, $remainingBalance), 2)
    ];
}

// Сохранение в БД (если указан listing_id)
if ($listingId) {
    try {
        $db = Database::getInstance()->getConnection();
        
        $stmt = $db->prepare("
            INSERT INTO financing_calculator 
            (listing_id, calculator_type, down_payment, loan_amount, interest_rate, 
             term_months, monthly_payment, total_payment, residual_value, calculation_data)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        ");
        
        $stmt->execute([
            $listingId,
            $calculatorType,
            $downPayment,
            $vehiclePrice - $downPayment,
            $interestRate,
            $termMonths,
            $result['monthly_payment'],
            $result['total_payment'],
            $residualValue ?? null,
            json_encode([
                'input' => $data,
                'result' => $result,
                'schedule' => $schedule
            ])
        ]);
    } catch (Exception $e) {
        // Игнорируем ошибки сохранения
    }
}

// Ответ
echo json_encode([
    'success' => true,
    'type' => $calculatorType,
    'result' => $result,
    'schedule' => $schedule,
    'summary' => [
        'vehicle_price' => $vehiclePrice,
        'down_payment' => $downPayment,
        'term_months' => $termMonths,
        'interest_rate' => $interestRate,
        'monthly_payment' => $result['monthly_payment'],
        'total_payment' => $result['total_payment'],
        'total_interest' => $result['total_interest']
    ]
]);
