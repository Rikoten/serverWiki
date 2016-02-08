define :setup_firewalld do

  firewalld_service 'http' do
    action :add
    zone   'public'
  end

  firewalld_service 'https' do
    action :add
    zone   'public'
  end

  firewalld_port '143/tcp' do
    action :add
    zone   'public'
  end

end
