class CardTablesController < ApplicationController

  def index
    tables = CardTable.all
    render json: tables
  end

  def show
    table = CardTable.find params[:id]
    game = table.board_game
    return head 404 if game.nil?

    player_name = params[:player]

    player_view = game.player_preview(player_name)
    return head 404 if player_view.nil?
    
    render json: player_view
  end


  def sit
    table = CardTable.find params[:id]

    name = params[:name]
    position = params[:position]

    unless name && position
      head 400
      return
    end

    unless table[position].nil?
      head 403
      return
    end

    table[position] = name

    if table.a && table.b && table.c && table.d
      table.board_game = BoardGame.create(a: table.a, b: table.b, c: table.c, d: table.d)
    end

    table.save
  end

  def show_team
    table = CardTable.find params[:card_table_id]
    game = table.board_game
    cards = params[:cards]
    return head 404 if game.nil?

    player_name = params[:player]
    return head 403 unless game.show_team(player_name, cards)
  end

  def replay
    table = CardTable.find params[:card_table_id]
    table.replay
  end

  def play
    table = CardTable.find params[:card_table_id]
    game = table.board_game
    return head 404 if game.nil?

    player_name = params[:player]
    cards = params[:cards]
    return head 403 unless game.play(player_name, cards)
  end

  def pass
    table = CardTable.find params[:card_table_id]
    game = table.board_game
    return head 404 if game.nil?

    player_name = params[:player]
    return head 403 unless game.pass(player_name)
  end


end
