<?php
require_once __DIR__ . '/../../core/config.php';
require_once __DIR__ . '/../../core/rate_limit.php';

rateLimit('send_email_code', 3, 300);

header('Content-Type: application/json; charset=utf-8');

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    jsonResponse(['error' => 'Method not allowed'], 405);
}

$input = getJsonInput();
$email = trim($input['email'] ?? '');

if ($email === '' || !filter_var($email, FILTER_VALIDATE_EMAIL)) {
    jsonResponse(['error' => 'Некорректный email'], 400);
}

// Проверяем, не занят ли email
$stmt = $pdo->prepare("SELECT id FROM users WHERE email = ?");
$stmt->execute([$email]);
if ($stmt->fetch()) {
    jsonResponse(['error' => 'Этот email уже используется'], 409);
}

// Генерируем 6-значный код
$verificationCode = str_pad(random_int(0, 999999), 6, '0', STR_PAD_LEFT);
$expires = time() + 600; // 10 минут

// Сохраняем код в сессии
session_start();
$_SESSION['email_code'] = hash('sha256', $verificationCode);
$_SESSION['email_code_email'] = $email;
$_SESSION['email_code_expires'] = $expires;
$_SESSION['email_code_attempts'] = 0;

// Отправляем письмо через PHPMailer или встроенный mail()
// Используем сокет SMTP напрямую (без PHPMailer)
$html = '<!DOCTYPE html>
<html lang="ru">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width,initial-scale=1.0">
  <title>sotspw</title>
</head>
<body style="margin:0;padding:40px 20px;background:#0a0a0a;font-family:Arial,Helvetica,sans-serif;">
  <table width="100%" cellpadding="0" cellspacing="0" border="0">
    <tr>
      <td align="center">
        <table width="600" cellpadding="0" cellspacing="0" border="0" style="max-width:600px;background:#141414;border:1px solid #222;border-radius:32px;overflow:hidden;">
          <tr>
            <td style="padding:50px 40px;text-align:center;">
              <!-- ЛОГОТИП -->
              <div style="display:inline-block;font-size:48px;font-weight:900;letter-spacing:-2px;color:#ff4d6a;">
                sotspw
              </div>

              <div style="margin-top:35px;width:120px;height:120px;line-height:120px;font-size:54px;background:#1e1e1e;border-radius:30px;margin-left:auto;margin-right:auto;">&#x2709;&#xFE0F;</div>
              
              <h1 style="color:#ffffff;font-size:32px;margin:35px 0 15px;">&#x41F;&#x43E;&#x434;&#x442;&#x432;&#x435;&#x440;&#x436;&#x434;&#x435;&#x43D;&#x438;&#x435; &#x43F;&#x43E;&#x447;&#x442;&#x44B;</h1>
              
              <p style="color:#888888;font-size:16px;line-height:1.7;margin:0;">&#x418;&#x441;&#x43F;&#x43E;&#x43B;&#x44C;&#x437;&#x443;&#x439;&#x442;&#x435; &#x43A;&#x43E;&#x434; &#x43D;&#x438;&#x436;&#x435; &#x434;&#x43B;&#x44F; &#x43F;&#x43E;&#x434;&#x442;&#x432;&#x435;&#x440;&#x436;&#x434;&#x435;&#x43D;&#x438;&#x44F; &#x434;&#x435;&#x439;&#x441;&#x442;&#x432;&#x438;&#x44F;.</p>
              
              <!-- БЛОК С КОДОМ -->
              <div style="margin-top:35px;background:#0f0f0f;border:1px solid #222;border-radius:24px;padding:25px;">
                <div style="font-size:56px;font-weight:900;letter-spacing:12px;text-transform:uppercase;color:#ff4d6a;">
                  ' . $verificationCode . '
                </div>
              </div>
              
              <p style="margin-top:25px;color:#888;font-size:14px;line-height:1.8;">&#x41A;&#x43E;&#x434; &#x434;&#x435;&#x439;&#x441;&#x442;&#x432;&#x438;&#x442;&#x435;&#x43B;&#x435;&#x43D; 10 &#x43C;&#x438;&#x43D;&#x443;&#x442;.<br>&#x41D;&#x438;&#x43A;&#x43E;&#x43C;&#x443; &#x43D;&#x435; &#x441;&#x43E;&#x43E;&#x431;&#x449;&#x430;&#x439;&#x442;&#x435; &#x44D;&#x442;&#x43E;&#x442; &#x43A;&#x43E;&#x434;.</p>
            </td>
          </tr>
          <tr>
            <td style="border-top:1px solid #222;padding:25px;text-align:center;">
              <p style="margin:0;color:#666;font-size:13px;">&copy; 2026 sotspw</p>
            </td>
          </tr>
        </table>
      </td>
    </tr>
  </table>
</body>
</html>';

$smtpHost = 'smtp.mail.ru';
$smtpPort = 465;
$smtpUser = 'sotspw@mail.ru';
$smtpPass = 'N5hQHwCR4KTxiLh9Ejhx';
$fromEmail = 'sotspw@mail.ru';
$fromName = 'sotspw';
$toEmail = $email;
$subject = '=?UTF-8?B?' . base64_encode('Подтверждение почты — sotspw') . '?=';

$sent = sendSmtpMail($smtpHost, $smtpPort, $smtpUser, $smtpPass, $fromEmail, $fromName, $toEmail, $subject, $html);

if (!$sent) {
    jsonResponse(['error' => 'Не удалось отправить письмо. Попробуйте позже.'], 500);
}

jsonResponse(['success' => true, 'message' => 'Код отправлен на ' . $email]);

function sendSmtpMail($host, $port, $user, $pass, $fromEmail, $fromName, $toEmail, $subject, $htmlBody) {
    $socket = @fsockopen('ssl://' . $host, $port, $errno, $errstr, 15);
    if (!$socket) return false;

    $boundary = md5(uniqid());

    function smtpExpect($socket, $code) {
        $resp = '';
        while ($line = fgets($socket, 515)) {
            $resp .= $line;
            if (substr($line, 3, 1) === ' ') break;
        }
        return substr($resp, 0, 3) === (string)$code;
    }

    function smtpSend($socket, $cmd) {
        fputs($socket, $cmd . "\r\n");
    }

    smtpExpect($socket, 220);
    smtpSend($socket, 'EHLO ' . gethostname());
    smtpExpect($socket, 250);
    smtpSend($socket, 'AUTH LOGIN');
    smtpExpect($socket, 334);
    smtpSend($socket, base64_encode($user));
    smtpExpect($socket, 334);
    smtpSend($socket, base64_encode($pass));
    if (!smtpExpect($socket, 235)) {
        fclose($socket);
        return false;
    }
    smtpSend($socket, 'MAIL FROM:<' . $fromEmail . '>');
    smtpExpect($socket, 250);
    smtpSend($socket, 'RCPT TO:<' . $toEmail . '>');
    if (!smtpExpect($socket, 250)) {
        fclose($socket);
        return false;
    }
    smtpSend($socket, 'DATA');
    smtpExpect($socket, 354);

    $headers  = 'From: =?UTF-8?B?' . base64_encode($fromName) . '?= <' . $fromEmail . ">\r\n";
    $headers .= 'To: ' . $toEmail . "\r\n";
    $headers .= 'Subject: ' . $subject . "\r\n";
    $headers .= 'MIME-Version: 1.0' . "\r\n";
    $headers .= 'Content-Type: text/html; charset=UTF-8' . "\r\n";
    $headers .= 'Content-Transfer-Encoding: base64' . "\r\n";
    $headers .= "\r\n";

    $body = chunk_split(base64_encode($htmlBody));

    smtpSend($socket, $headers . $body . "\r\n.");
    $ok = smtpExpect($socket, 250);
    smtpSend($socket, 'QUIT');
    fclose($socket);
    return $ok;
}
