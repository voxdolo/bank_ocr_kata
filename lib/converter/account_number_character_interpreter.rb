class AccountNumberCharacterIntepreter
  attr_accessor :matrix

  DIGITS = {
    ' _ ' \
    '| |' \
    '|_|' => 0,
    '   ' \
    '  |' \
    '  |' => 1,
    ' _ ' \
    ' _|' \
    '|_ ' => 2,
    ' _ ' \
    ' _|' \
    ' _|' => 3,
    '   ' \
    '|_|' \
    '  |' => 4,
    ' _ ' \
    '|_ ' \
    ' _|' => 5,
    ' _ ' \
    '|_ ' \
    '|_|' => 6,
    ' _ ' \
    '  |' \
    '  |' => 7,
    ' _ ' \
    '|_|' \
    '|_|' => 8,
    ' _ ' \
    '|_|' \
    ' _|' => 9,
  }

  def initialize(matrix)
    self.matrix = matrix
  end

  def digit
    DIGITS[mash] or raise "#{pretty} is not a valid character matrix"
  end

  private

  def pretty
    self.matrix.map(&:join).join("\n")
  end

  def mash
    self.matrix.flatten.join
  end

end
