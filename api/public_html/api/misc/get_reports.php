<?php
require_once __DIR__ . '/../../core/config.php';

authenticateAdmin();

$stmt = $pdo->query("SELECT * FROM reports ORDER BY id DESC");
jsonResponse($stmt->fetchAll());
