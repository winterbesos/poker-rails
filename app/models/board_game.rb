class BoardGame < ApplicationRecord
  has_many :board_game_records
  # status 0 未开始
  #        1 明身份
  #        2 进行中
  #        99 已结束

  RED_TEN = ["0h", "0d"]

  BASE_INDEX_ORDER = [
    "6", "7", "8", "9", "0", "J", "Q", "K", "A", "2"
  ]
  
  SUNZA_ENABLE_INDEX_ORDER = [
    "6", "7", "8", "9", "0", "J", "Q", "K", "A"
  ]

  BASE_POOL = [
    "6s", "7s", "8s", "9s", "0s", "Js", "Qs", "Ks", "As", "2s",
    "6h", "7h", "8h", "9h", "0h", "Jh", "Qh", "Kh", "Ah", "2h",
    "6d", "7d", "8d", "9d", "0d", "Jd", "Qd", "Kd", "Ad", "2d",
    "6c", "7c", "8c", "9c", "0c", "Jc", "Qc", "Kc", "Ac", "2c"
  ]

  PRIORITY_CARD = "6h"

  before_create do
    shuffle
  end

  def shuffle
    pool = BASE_POOL.clone.shuffle
    a = pool.slice(0, 10)
    b = pool.slice(10, 10)
    c = pool.slice(20, 10)
    d = pool.slice(30, 10)

    team_a = []
    team_b = []

    self.status = 1
    self.a_hand = a.sort { |a,b| BASE_INDEX_ORDER.index(a[0,1]) <=> BASE_INDEX_ORDER.index(b[0,1]) }
    self.current_player = 'a' if a.include? PRIORITY_CARD
    team_a.append('a') if a.include?("0h") || a.include?("0d")
    team_b.append('a') if !a.include?("0h") && !a.include?("0d")

    self.b_hand = b.sort { |a,b| BASE_INDEX_ORDER.index(a[0,1]) <=> BASE_INDEX_ORDER.index(b[0,1]) }
    self.current_player = 'b' if b.include? PRIORITY_CARD
    team_a.append('b') if b.include?("0h") || b.include?("0d")
    team_b.append('b') if !b.include?("0h") && !b.include?("0d")

    self.c_hand = c.sort { |a,b| BASE_INDEX_ORDER.index(a[0,1]) <=> BASE_INDEX_ORDER.index(b[0,1]) }
    self.current_player = 'c' if c.include? PRIORITY_CARD
    team_a.append('c') if c.include?("0h") || c.include?("0d")
    team_b.append('c') if !c.include?("0h") && !c.include?("0d")
    
    self.d_hand = d.sort { |a,b| BASE_INDEX_ORDER.index(a[0,1]) <=> BASE_INDEX_ORDER.index(b[0,1]) }
    self.current_player = 'd' if d.include? PRIORITY_CARD
    team_a.append('d') if d.include?("0h") || d.include?("0d")
    team_b.append('d') if !d.include?("0h") && !d.include?("0d")

    self.team_a = team_a
    self.team_b = team_b
    self.show = 0
  end

  def is_finished
    return self.status == 99
  end

  def remaining_players_count
    count = 0
    count += 1 unless JSON.parse(self.a_hand).empty?
    count += 1 unless JSON.parse(self.b_hand).empty?
    count += 1 unless JSON.parse(self.c_hand).empty?
    count += 1 unless JSON.parse(self.d_hand).empty?
    return count
  end

  def player_preview(player_name)
    player = player_by_player_name(player_name)
    return nil if player.nil?

    pool = []
    for r in board_game_records.order(:created_at).reverse_order[0,4]
      break if pool.select {|pr| pr.player == r.player}.size > 0
      pool.append(r)
    end
    last_a = nil
    last_b = nil
    last_c = nil
    last_d = nil
    for c in pool
      if c.player == 'a' && last_a.nil?
        last_a = c
      elsif c.player == 'b' && last_b.nil?
        last_b = c
      elsif c.player == 'c' && last_c.nil?
        last_c = c
      elsif c.player == 'd' && last_d.nil?
        last_d = c
      end
    end
    return {
      id: self.id,
      status: self.status,
      player: player,
      players: {
        a: {
          name: self.a,
          score: self.a_result,
          last_play: last_a.nil? ? nil : {
            action: last_a.content.nil? ? 'PASS' : 'PLAY',
            cards: last_a.content.nil? ? nil : JSON.parse(last_a.content),
            index: last_a.id,
          },
          playing: is_current_player(self.a),
          passable: passable(self.a),
          cards: player == 'a' ? JSON.parse(self[player + '_hand']) : nil,
          showCards: self.show_a.nil? ? nil : JSON.parse(self.show_a),
          single: player_hand_cards('a').size == 1,
          ranking: finish_order.index('a'),
        },
        b: {
          name: self.b,
          score: self.b_result,
          last_play: last_b.nil? ? nil : {
            action: last_b.content.nil? ? 'PASS' : 'PLAY',
            cards: last_b.content.nil? ? nil : JSON.parse(last_b.content),
            index: last_b.id,
          },
          playing: is_current_player(self.b),
          passable: passable(self.b),
          cards: player == 'b' ? JSON.parse(self[player + '_hand']) : nil,
          showCards: self.show_b.nil? ? nil : JSON.parse(self.show_b),
          single: player_hand_cards('b').size == 1,
          ranking: finish_order.index('b'),
        },
        c: {
          name: self.c,
          score: self.c_result,
          last_play: last_c.nil? ? nil : {
            action: last_c.content.nil? ? 'PASS' : 'PLAY',
            cards: last_c.content.nil? ? nil : JSON.parse(last_c.content),
            index: last_c.id,
          },
          playing: is_current_player(self.c),
          passable: passable(self.c),
          cards: player == 'c' ? JSON.parse(self[player + '_hand']) : nil,
          showCards: self.show_c.nil? ? nil : JSON.parse(self.show_c),
          single: player_hand_cards('c').size == 1,
          ranking: finish_order.index('c'),
        },
        d: {
          name: self.d,
          score: self.d_result,
          last_play: last_d.nil? ? nil : {
            action: last_d.content.nil? ? 'PASS' : 'PLAY',
            cards: last_d.content.nil? ? nil : JSON.parse(last_d.content),
            index: last_d.id,
          },
          playing: is_current_player(self.d),
          passable: passable(self.d),
          cards: player == 'd' ? JSON.parse(self[player + '_hand']) : nil,
          showCards: self.show_d.nil? ? nil : JSON.parse(self.show_d),
          single: player_hand_cards('d').size == 1,
          ranking: finish_order.index('d'),
        }
      },
    }
  end

  def player_by_player_name(player_name)
    player = nil
    if player_name == self.a
      player = 'a'
    elsif player_name == self.b
      player = 'b'
    elsif player_name == self.c
      player = 'c'
    elsif player_name == self.d
      player = 'd'
    else
      player = nil
    end
    return player
  end

  def is_current_player(player_name)
    return player_name == self[self.current_player]
  end

  def check_finish_status
    team_a_finish = true
    for tai in JSON.parse(self.team_a)
      team_a_finish = false unless JSON.parse(self[tai + '_hand']).empty?
    end

    team_b_finish = true
    for tai in JSON.parse(self.team_b)
      team_b_finish = false unless JSON.parse(self[tai + '_hand']).empty?
    end

    finished = team_a_finish || team_b_finish
    return finished
  end

  def is_shown?
    return self.show & 0b1111 != 0
  end

  def is_team_a_shown?
    return false unless is_shown?
    ta = JSON.parse(self.team_a)
    showPlayer = ['a', 'b', 'c', 'd'][Math.log(self.show, 2)]
    return ta.include? showPlayer
  end

  def unfinished_players
    return ['a', 'b', 'c', 'd'] - finish_order
  end

  def settle
    order = finish_order
    steps = [0, 2, 5, 10, 20, 40, 80, 160]

    ta = JSON.parse(self.team_a)
    tb = JSON.parse(self.team_b)
    if ta.size == 1 # 1 v 3
      tap = ta[0]
      if order.size == 1 # 红了
        if is_shown? # 亮/踢
          if is_team_a_shown? # 亮
            self[tap + '_result'] = steps[4] * 3
            tb.each {|tbi| self[tbi + '_result'] = -steps[4] }
          else # 踢
            self[tap + '_result'] = steps[5] * 3
            tb.each {|tbi| self[tbi + '_result'] = -steps[5] }
          end
        else
          self[tap + '_result'] = steps[3] * 3
          tb.each {|tbi| self[tbi + '_result'] = -steps[3] }
        end
      elsif order.size == 2 # 抓两个
        if is_shown?
          if is_team_a_shown?
            self[tap + '_result'] = steps[3] * 2
            tb.each {|tbi| self[tbi + '_result'] = (unfinished_players.include?(tbi) ? -steps[3] : 0)}
          else
            self[tap + '_result'] = steps[4] * 2
            tb.each {|tbi| self[tbi + '_result'] = (unfinished_players.include?(tbi) ? -steps[4] : 0)}
          end
        else
          self[tap + '_result'] = steps[2] * 2
          tb.each {|tbi| self[tbi + '_result'] = (unfinished_players.include?(tbi) ? -steps[2] : 0)}
        end
      elsif order.size == 3 && order.include?(tap) # 抓一个
        if is_shown?
          if is_team_a_shown?
            self[tap + '_result'] = steps[2]
            tb.each {|tbi| self[tbi + '_result'] = (unfinished_players.include?(tbi) ? -steps[2] : 0)}
          else
            self[tap + '_result'] = steps[3]
            tb.each {|tbi| self[tbi + '_result'] = (unfinished_players.include?(tbi) ? -steps[3] : 0)}
          end
        else
          self[tap + '_result'] = steps[1]
          tb.each {|tbi| self[tbi + '_result'] = (unfinished_players.include?(tbi) ? -steps[1] : 0)}
        end
      elsif !order.include? tap # 黑了
        if is_shown?
          if is_team_a_shown? # 踢
            self[tap + '_result'] = -steps[5] * 3
            tb.each {|tbi| self[tbi + '_result'] = steps[5] }
          else
            self[tap + '_result'] = -steps[4] * 3
            tb.each {|tbi| self[tbi + '_result'] = steps[4] }
          end
        else
          self[tap + '_result'] = -steps[3] * 3
          tb.each {|tbi| self[tbi + '_result'] = steps[3] }
        end
      end
    else # 2 v 2
      if unfinished_players.size == 2 && (unfinished_players - tb).empty? # a完胜
        if is_shown?
          if is_team_a_shown?
            ta.each {|tbi| self[tbi + '_result'] = steps[3] }
            tb.each {|tbi| self[tbi + '_result'] = -steps[3] }
          else
            ta.each {|tbi| self[tbi + '_result'] = steps[4] }
            tb.each {|tbi| self[tbi + '_result'] = -steps[4] }
          end
        else
          ta.each {|tbi| self[tbi + '_result'] = steps[2] }
          tb.each {|tbi| self[tbi + '_result'] = -steps[2] }
        end
      elsif unfinished_players.size == 2 && (unfinished_players - ta).empty? #b完胜
        if is_shown?
          if is_team_a_shown? # 踢
            ta.each {|tbi| self[tbi + '_result'] = -steps[4] }
            tb.each {|tbi| self[tbi + '_result'] = steps[4] }
          else
            ta.each {|tbi| self[tbi + '_result'] = -steps[3] }
            tb.each {|tbi| self[tbi + '_result'] = steps[3] }
          end
        else
          ta.each {|tbi| self[tbi + '_result'] = -steps[2] }
          tb.each {|tbi| self[tbi + '_result'] = steps[2] }
        end
      elsif ta.include?(finish_order[0]) && unfinished_players.size == 1 && tb.include?(unfinished_players[0]) #a抓一个
        if is_shown?
          if is_team_a_shown?
            ta.each {|tbi| self[tbi + '_result'] = steps[2] }
            tb.each {|tbi| self[tbi + '_result'] = -steps[2] }
          else
            ta.each {|tbi| self[tbi + '_result'] = steps[3] }
            tb.each {|tbi| self[tbi + '_result'] = -steps[3] }
          end
        else
          ta.each {|tbi| self[tbi + '_result'] = steps[1] }
          tb.each {|tbi| self[tbi + '_result'] = -steps[1] }
        end
      elsif tb.include?(finish_order[0]) && unfinished_players.size == 1 && ta.include?(unfinished_players[0]) #b抓一个
        if is_shown?
          if is_team_a_shown? # 踢
            ta.each {|tbi| self[tbi + '_result'] = -steps[3] }
            tb.each {|tbi| self[tbi + '_result'] = steps[3] }
          else
            ta.each {|tbi| self[tbi + '_result'] = -steps[2] }
            tb.each {|tbi| self[tbi + '_result'] = steps[2] }
          end
        else
          ta.each {|tbi| self[tbi + '_result'] = -steps[1] }
          tb.each {|tbi| self[tbi + '_result'] = steps[1] }
        end
      else #平局
        ta.each {|tai| self[tai + '_result'] = steps[0] }
        tb.each {|tbi| self[tbi + '_result'] = steps[0] }
      end
    end
    self.save
  end

  def play(player_name, cards)
    self.with_lock do
      return false if cards.empty?
      return false unless playable(player_name, cards)

      player = self.current_player
      hand_cards = JSON.parse self[player + '_hand']
      remaining_cards = hand_cards - cards
      self[player + '_hand'] = remaining_cards
      self.last_cards = cards
      self.last_player = self.current_player

      self.current_player = self.next_no_finished_player(self.current_player)
      if remaining_cards.empty?
        self.shose_owner = self.next_shown_couple(player)
      else
        self.shose_owner = nil
      end

      finished = check_finish_status
      self.status = finished ? 99 : 2
      self.current_player = nil if finished
      self.save

      self.board_game_records.create!(:player => player, :content => cards, :status => remaining_cards.empty? ? 99 : 2)

      if finished
        self.settle
      end
    end
  end

  def finish_order
    order = []
    for r in self.board_game_records.order(:created_at)
      order.append(r.player) if r.status == 99
    end
    return order
  end

  def pass(player_name)
    self.with_lock do
      return false unless passable(player_name)

      player = self.current_player
      self.current_player = self.next_no_finished_player(self.current_player)

      if self.status == 1
        self.show = self.show | (player_to_mask(player) << 4)
        self.status = 2 if show_loop_finished
      elsif self.status == 2
        pool = board_game_records.order(:created_at).reverse_order.limit(remaining_players_count - 1)
        use_shose = true
        for r in pool
          use_shose = false unless r.content.nil?
        end

        if use_shose && !self.shose_owner.nil?
          self.last_player = self.shose_owner
          self.current_player = self.shose_owner
          self.last_cards = nil
        end
        self.board_game_records.create!(:player => player, :content => nil)
      end

      self.save
    end
  end

  def show_loop_finished
    return (self.show & (0b1111 << 4)) == 0b1111 << 4
  end

  def show_team(player_name, cards)
    self.with_lock do
      return false unless show_teamable(player_name, cards)
      
      player = self.current_player
      return false if (is_triple_bomb(cards) || is_quadruple_bomb(cards)) && !(player_hand_cards(player) & RED_TEN).empty?
      self.show = self.show | (player_to_mask(player) << 4)
      self.show = self.show | player_to_mask(player)

      self.show_a = JSON.parse(self.a_hand) & RED_TEN
      self.show_b = JSON.parse(self.b_hand) & RED_TEN
      self.show_c = JSON.parse(self.c_hand) & RED_TEN
      self.show_d = JSON.parse(self.d_hand) & RED_TEN
      self['show_' + player] = cards

      self.current_player = 'a' if player_hand_cards('a').include? PRIORITY_CARD
      self.current_player = 'b' if player_hand_cards('b').include? PRIORITY_CARD
      self.current_player = 'c' if player_hand_cards('c').include? PRIORITY_CARD
      self.current_player = 'd' if player_hand_cards('d').include? PRIORITY_CARD

      self.status = 2
      self.save
    end
  end

  private
  def player_to_mask(player)
    if player == 'a'
      return 1 << 0
    elsif player == 'b'
      return 1 << 1
    elsif player == 'c'
      return 1 << 2
    elsif player == 'd'
      return 1 << 3
    else
      return 0
    end
  end

  def show_teamable(player_name, cards)
    return false unless self.status == 1
    return false unless is_current_player(player_name)

    hand_cards = player_hand_cards(self.current_player)
    return false unless contains_cards(hand_cards, cards)
    return false unless is_single_red_ten(cards) || is_double_red_ten(cards) || is_triple_bomb(cards) || is_quadruple_bomb(cards)
    return false if contains_double_red_ten(hand_cards) && is_single_red_ten(cards)
    return true
  end

  def player_hand_cards(player)
    JSON.parse(self[player + '_hand'])
  end

  def player_show_cards(player)
    JSON.parse(self['show_' + player])
  end

  def contains_double_red_ten(cards)
    return cards.include?("0h") && cards.include?("0d")
  end

  def contains_cards(hand_cards, cards)
    hcset = hand_cards.to_set
    for card in cards
      return false unless hcset.include?(card)
    end
    return true
  end

  def contains_any_cards(cardsA, cardsB)
    set = cardsA.to_set
    for card in cardsB
      return true if set.include?(card)
    end
    return false
  end

  def passable(player_name)
    return false unless is_current_player(player_name)
    return self.last_player != nil && self.last_player != self.current_player if self.status == 2
    return true
  end

  def valid(cards)
    return is_single(cards) || is_couple(cards) || is_shunza(cards) || is_couple_shunza(cards) || is_triple_bomb(cards) || is_quadruple_bomb(cards)
  end

  def initiative_show_validate(player, cards)
    mask = player_to_mask(player)
    return true unless self.show & mask > 0 # 主动亮牌校验
    show_cards = player_show_cards(player)
    return true if is_single_red_ten(show_cards) # 单红十没有限制
    return false if contains_any_cards(cards, show_cards) && (show_cards.size != cards.size || !(show_cards - cards).empty?) # 出牌包含任何一张亮牌 且 出牌和亮牌不完全一样
    return true
  end

  def red_six_play_first_validate(cards)
    hand_cards = player_hand_cards(self.current_player)
    return true if hand_cards.size < 10    
    return true unless hand_cards.include?(PRIORITY_CARD)
    six_count = hand_cards.map { |c| c[0] }.map { |i| BASE_INDEX_ORDER.index(i) }.sort.select {|i| i == 0}.size
    return true if six_count >= 3
    return true if cards.include?(PRIORITY_CARD)
    return false
  end

  def playable(player_name, cards)
    return false unless valid(cards)
    return false unless is_current_player(player_name)
    return false unless red_six_play_first_validate(cards)
    return false unless contains_cards(player_hand_cards(self.current_player), cards)
    return false unless initiative_show_validate(self.current_player, cards)
    return true if self.last_player == self.current_player
    return true if self.last_cards.nil?

    last_cards = JSON.parse self.last_cards

    if is_double_red_ten(cards)
      return true
    elsif is_double_red_ten(last_cards)
      return false
    elsif is_single(last_cards)
      if is_single(cards)
        return base_cards_index(cards) > base_cards_index(last_cards)
      elsif is_couple(cards) || is_shunza(cards) || is_couple_shunza(cards)
        return false
      else
        return true
      end
    elsif is_couple(last_cards)
      if is_couple(cards)
        return base_cards_index(cards) > base_cards_index(last_cards)
      elsif is_single(cards) || is_shunza(cards) || is_couple_shunza(cards)
        return false
      else
        return true
      end
    elsif is_shunza(last_cards)
      if is_shunza(cards)
        return base_cards_index(cards) > base_cards_index(last_cards)
      elsif is_single(cards) || is_couple(cards) || is_couple_shunza(cards)
        return false
      else
        return true
      end
    elsif is_couple_shunza(last_cards)
      if is_couple_shunza(cards)
        return base_cards_index(cards) > base_cards_index(last_cards)
      elsif is_single(cards) || is_couple(cards) || is_shunza(cards) || is_triple_bomb(cards)
        return false
      else
        return true
      end
    elsif is_triple_bomb(last_cards)
      if is_triple_bomb(cards)
        return base_cards_index(cards) > base_cards_index(last_cards)
      elsif is_single(cards) || is_couple(cards) || is_shunza(cards) || is_couple_shunza(cards)
        return false
      else
        return true
      end
    elsif is_quadruple_bomb(last_cards)
      if is_quadruple_bomb(cards)
        return base_cards_index(cards) > base_cards_index(last_cards)
      else
        return true
      end
    else 
      return false
    end
  end

  def base_cards_index(cards)
    if self.is_single(cards)
      return 999 if cards.include?("0h") || cards.include?("0d")
      return BASE_INDEX_ORDER.index(cards[0][0,1])
    elsif self.is_couple(cards)
      return BASE_INDEX_ORDER.index(cards[0][0,1])
    elsif self.is_shunza(cards)
      return card_indexes = cards.map { |c| c[0][0,1] }.map { |i| SUNZA_ENABLE_INDEX_ORDER.index(i) }.sort[0]
    elsif self.is_couple_shunza(cards)
      return card_indexes = cards.map { |c| c[0][0,1] }.map { |i| SUNZA_ENABLE_INDEX_ORDER.index(i) }.sort[0]
    elsif self.is_triple_bomb(cards)
      return BASE_INDEX_ORDER.index(cards[0][0,1])
    elsif self.is_quadruple_bomb(cards)
      return BASE_INDEX_ORDER.index(cards[0][0,1])
    end
  end

  def is_single(cards)
    return cards.size == 1
  end

  def is_couple(cards)
    return false if cards.size != 2
    return cards[0][0] == cards[1][0]
  end

  def is_shunza(cards)
    return false if cards.size < 3
    return false if contains_any_cards(cards, ["2s", "2h", "2d", "2c"])
    card_indexes = cards.map { |c| c[0] }.map { |i| SUNZA_ENABLE_INDEX_ORDER.index(i) }.sort

    last_index = nil
    for i in card_indexes
      if last_index.nil?
        last_index = i
        next
      end

      return false if i != last_index + 1
      last_index = i
    end

    return true
  end

  def is_couple_shunza(cards)
    return false if cards.size < 6
    card_indexes = cards.map { |c| c[0] }.map { |i| SUNZA_ENABLE_INDEX_ORDER.index(i) }.sort


    helf_couple = nil
    last_index = nil
    for i in card_indexes
      if helf_couple.nil?
        if last_index.nil?
          helf_couple = i
          last_index = i
          next
        end

        return false if i != last_index + 1
        last_index = i
        helf_couple = i
      else
        return false if helf_couple != i
        helf_couple = nil
      end
    end

    return true
  end

  def is_triple_bomb(cards)
    return false if cards.size != 3
    return cards.map {|c| c[0]}.uniq.size == 1
  end

  def is_quadruple_bomb(cards)
    return false if cards.size != 4
    return cards.map {|c| c[0]}.uniq.size == 1
  end

  def is_single_red_ten(cards)
    return false unless cards.size == 1
    return cards.include?("0h") || cards.include?("0d")
  end

  def is_double_red_ten(cards)
    return false if cards.size != 2
    return cards.include?("0h") && cards.include?("0d")
  end

  def next_player(c)
    return nil if c.nil?

    n = c
    if n == 'a'
      n = 'b'
    elsif n == 'b'
      n = 'c'
    elsif n == 'c'
      n = 'd'
    elsif n == 'd'
      n = 'a'
    end

    return n
  end

  def player_finished(player)
    player_hand_cards(player).empty?
  end

  def next_no_finished_player(c)
    return nil if c.nil?

    n = c
    if n == 'a'
      n = 'b'
    elsif n == 'b'
      n = 'c'
    elsif n == 'c'
      n = 'd'
    elsif n == 'd'
      n = 'a'
    end

    while player_finished(n) && n != c
      if n == 'a'
        n = 'b'
      elsif n == 'b'
        n = 'c'
      elsif n == 'c'
        n = 'd'
      elsif n == 'd'
        n = 'a'
      end
    end
    return nil if n == c
    return n
  end

  def next_shown_couple(c)
    return next_player(c) if (self.show & 0b1111) == 0 # not shown

    ta = JSON.parse(self.team_a)
    in_ta = ta.include?(c)

    n = next_player(c)
    while in_ta != ta.include?(n) && n != c
      n = self.next_player(n)
    end

    return nil if n == c
    return n
  end
end
