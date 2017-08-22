require_relative '../models/init'

# Create locations so that UI can see them.
('A'..'E').each do |row|
  (1..9).each do |column|
    Location.create(
      row: row,
      column: column
    )
  end
end
