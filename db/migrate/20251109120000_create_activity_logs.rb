class CreateActivityLogs < ActiveRecord::Migration[7.0]
  def change
    create_table :activity_logs do |t|
      t.references :user, null: true, foreign_key: { on_delete: :nullify }
      t.string :action, null: false
      t.string :subject_type
      t.bigint :subject_id
      t.text :message, null: false
      t.jsonb :metadata, default: {}, null: false

      t.timestamps
    end

    add_index :activity_logs, [:subject_type, :subject_id]
    add_index :activity_logs, :created_at
  end
end

