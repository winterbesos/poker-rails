class CardTable < ApplicationRecord
  belongs_to :board_game, optional: true

  def replay
    self.board_game = BoardGame.create(a: self.a, b: self.b, c: self.c, d: self.d)
    self.save
  end
end
