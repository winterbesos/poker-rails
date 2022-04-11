class BoardGameRecord < ApplicationRecord
  belongs_to :board_game

  # status  events
  # 2 normal
  # 99 finished
  #
  def is_finished_events
    return self.status == 99
  end
end
