-- TEST 1: Usuario aprobado (debe generar token)
SELECT request_password_reset('admin@test.com', '127.0.0.1'::INET) as resultado;
