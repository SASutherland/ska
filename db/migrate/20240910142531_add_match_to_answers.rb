class AddMatchToAnswers < ActiveRecord::Migration[6.0]
  def change
    add_column :answers, :match, :string
  end
end
