# frozen_string_literal: true

namespace :hyku_addons do
  namespace :superadmin do
    desc 'Create a superadmin user'
    task :create, [:email, :password] => [:environment] do |_cmd, args|
      puts 'Creating a superadmin user.'
      user = create_or_prompt_to_create_user(args)
      user.add_role(:superadmin)
      puts "User (#{user.user_key}) created and granted superadministrator privileges"
    end

    def create_or_prompt_to_create_user(args)
      User.find_or_create_by!(email: args.email || prompt_for_email) do |u|
        puts 'User not found. Enter a password to create the user.'
        u.password = args.password || prompt_for_password
      end
    rescue StandardError => e
      puts e
      retry
    end

    def prompt_for_email
      print 'Email: '
      $stdin.gets.chomp
    end

    def prompt_for_password
      begin
        system 'stty -echo'
        print 'Password (must be 8+ characters): '
        password = $stdin.gets.chomp
        puts "\n"
      ensure
        system 'stty echo'
      end
      password
    end
  end
end
