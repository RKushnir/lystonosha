class CreateLystonosha < ActiveRecord::Migration
  def change
    create_table :conversations do |t|
      t.string :subject, limit: 200
      t.timestamps
    end

    create_table :messages do |t|
      t.string :subject, limit: 200
      t.text :body
      t.references :sender, polymorphic: true
      t.references :conversation, null: false
      t.timestamps
    end

    create_table :receipts do |t|
      t.references :recipient, polymorphic: true, null: false
      t.references :message, null: false
      t.boolean :read, default: false
      t.string :mailbox, limit: 10
    end

    add_index :messages, :conversation_id
    add_index :receipts, [:recipient_id, :recipient_type, :mailbox]
    add_index :receipts, :message_id
  end
end
