$remote_lrs = Xapi.create_remote_lrs(
    end_point: ENV['LRS_ENDPOINT'],
    user_name: ENV['LRS_USERNAME'],
    password: ENV['LRS_PASSWORD']
)
