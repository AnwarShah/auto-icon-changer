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

def change_icon_theme(name)
  `gsettings set org.gnome.desktop.interface icon-theme #{name}`
end

def fetch_installed_theme_names
  theme_names = []
  theme_names += retrieve_icon_theme_names("/usr/share/icons")
  theme_names += retrieve_icon_theme_names("/home/anwar/.local/share/icons")
  theme_names.sort_by { |theme_name| theme_name.downcase }
end

if ARGV.include?("-i")
  chosen_theme_name = get_theme_choice_from_user(fetch_installed_theme_names)
  puts "You've chosen #{chosen_theme_name}"
  puts "Changing icon theme to #{chosen_theme_name} ..."
  change_icon_theme(chosen_theme_name)
else
  icon_theme_names = fetch_installed_theme_names
  icon_theme_names.each do |theme_name|
    puts "Changing icon theme to #{theme_name} ..."
    change_icon_theme(theme_name)
    sleep 5*60 # change per 5 minutes
  end
end

