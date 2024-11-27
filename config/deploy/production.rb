# server "13.208.242.86", user: "ubuntu"
set :rails_env, 'production'
server '15.152.37.248', user: 'deploy', roles: %w{app db web}

