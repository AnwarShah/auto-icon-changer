require 'pathname'

# get all icon theme names from a directory
def retrieve_icon_theme_names(theme_location)
  pn_location = Pathname.new theme_location

  theme_dirs = pn_location.children.select { |d| d.directory? } # themes must be directory

  icon_themes = theme_dirs.select do |theme_dir|
    begin
      theme_dir unless theme_dir.children.any? { |c| c.basename.fnmatch "cursors" } # if there is a 'cursors' directory
    rescue
      puts "Errors occurred while processing #{theme_dir}"
    end
  end
  icon_themes.map! { |icon_theme_pn| icon_theme_pn.basename.to_s }
end

# pretty print icon theme names with number
def display_theme_names(theme_names)
  theme_names.each_with_index do |name, index|
    puts "#{index+1}: #{name}"
  end
end

# get choice from user
def get_theme_choice_from_user(icon_theme_names)
  display_theme_names(icon_theme_names)
  puts "Choose an icon theme by typing its number"
  chosen = STDIN.gets.chomp.to_i

  while chosen < 1 || chosen > icon_theme_names.count
    puts "Invalid choice. Please type a number between 1-#{icon_theme_names.count}"
    chosen = STDIN.gets.chomp.to_i
  end
  icon_theme_names[chosen-1]
end

def get_current_theme_name
  `gsettings get org.gnome.desktop.interface icon-theme`.strip.gsub('\'','')
end

def change_icon_theme(name)
  `gsettings set org.gnome.desktop.interface icon-theme #{name}`
end

def fetch_installed_theme_names
  theme_names = []
  theme_names += retrieve_icon_theme_names("/usr/share/icons")
  theme_names += retrieve_icon_theme_names("/home/anwar/.local/share/icons")
  theme_names.sort_by { |theme_name| theme_name.downcase }
end

def run_in_daemon_mode(period, theme_names, current = 0)
  loop do
    current %= theme_names.count # rewind if last theme is reached
    theme_name = theme_names[current]
    puts "Changing icon theme to #{theme_name} ..."
    change_icon_theme(theme_name)
    current += 1
    sleep period*60
  end
end

if ARGV.include?("-i")
  chosen_theme_name = get_theme_choice_from_user(fetch_installed_theme_names)
  puts "You've chosen #{chosen_theme_name}"
  puts "Changing icon theme to #{chosen_theme_name} ..."
  change_icon_theme(chosen_theme_name)
elsif ARGV.include?('-d') or ARGV.include?('--daemon')
  idx = ARGV.index('-d') || ARGV.index('--daemon') # index of daemon parameter
  period = ARGV[idx+1].to_i # if it's nil, invalid the result will be 0

  installed_theme_names = fetch_installed_theme_names
  current_index = installed_theme_names.index(get_current_theme_name)

  if period.zero?
    puts "Invalid or no period specified, Setting to 5 minutes ..."
    period = 5
  else
    puts "Changing icon theme per #{period} min. ..."
  end

  run_in_daemon_mode(period, fetch_installed_theme_names, current_index+1)
else
  puts "USAGE: icon_changer.rb -i (interactive mode)"
  puts " or    icon_changer -d, --daemon [period in minute] (run in daemon mode)"
end

