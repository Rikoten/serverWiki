#
# UNIXユーザー追加
#
setup_user "hikalium" do
	password "$1$E5n1H2ql$2WTJjgxTLuTMb1AflY9O1/"
	rsakey "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC/VWeaWtwrPRCDeJRYbL909iVzOPjspwWTdKk6W/Kqv7i/dxDXiTkNLlwsjwpi+Qw0M1TOSc1TGyaj2cS8w2X0LmMHJ15pqxlwn3qz9NlPH6CusX3yAWAO9V9iftU1o3ZfZzAwGAPTU0XqqQjROkYlydPDw3LdfoEGxNrjwH1rw148dSlsy4lAjiH3BfXijBEHrHvFqFB67Ws7lQca9dbp1I6We/W4JHazI2FytDSqMqnmMuZD2rm5Jp3mN5Z+KpKm6BBQpwIBWYmD5Fa1o/V5Ch7V27FwSUSxnZY8lyBPDen6LM35ZKTBuxU6wUsxXc2SbIXFwibljKvas8y6euuT hikalium@test.rikoten.com"
end

group "wheel" do
	action [:modify]
	members ["hikalium"]
end

