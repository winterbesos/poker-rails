class CardTable < ApplicationRecord
  belongs_to :board_game, optional: true

  def sit(name, position)
    return false unless sitable?(position)

    self[position] = name
    self.reset_score
    self.save
  end

  def stand(name)
    self.a = nil if self.a == name
    self.b = nil if self.b == name
    self.c = nil if self.c == name
    self.d = nil if self.d == name

    self.save
  end

  def settle(a, b, c, d)
    self.a_score += a
    self.b_score += b
    self.c_score += c
    self.d_score += d
    self.save
  end

  def replay
    self.board_game = BoardGame.create(a: self.a, b: self.b, c: self.c, d: self.d)
    self.save
  end

  private
  def sitable?(position)
    return self[position].nil?
  end

  def reset_score
    self.a_score = 0
    self.b_score = 0
    self.c_score = 0
    self.d_score = 0
  end
end
