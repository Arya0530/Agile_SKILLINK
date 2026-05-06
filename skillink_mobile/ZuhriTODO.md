# Add Save Login, Logout Confirmation, Reset Password to email
tambahkan di .env kalian
- dibagian MAIL ubah semuanya dengan ini:

MAIL_MAILER=smtp
MAIL_HOST=smtp.gmail.com
MAIL_PORT=587
MAIL_USERNAME=skillinkappadmin@gmail.com
MAIL_PASSWORD=jwwiodrdqdgvpipv
MAIL_ENCRYPTION=tls
MAIL_FROM_ADDRESS=skillinkappadmin@gmail.com
MAIL_FROM_NAME="SKILLINK"

- dibagian APP_URL gantikan dengan url dari ngrok / url website
contoh : APP_URL=https://unphrased-noninstinctively-julietta.ngrok-free.dev