class CreateLystonosha < ActiveRecord::Migration
  def change
    create_table :lystonosha_conversations do |t|
      t.string :subject, limit: 200
      t.timestamps
    end

    create_table :lystonosha_messages do |t|
      t.string :subject, limit: 200
      t.text :body
      t.references :sender, polymorphic: true
      t.references :conversation, null: false
      t.timestamps
    end

    create_table :lystonosha_receipts do |t|
      t.references :recipient, polymorphic: true, null: false
      t.references :message, null: false
      t.boolean :read, default: false
      t.string :mailbox, limit: 10
    end

    add_index :lystonosha_messages, :conversation_id
    add_index :lystonosha_receipts, [:recipient_id, :recipient_type, :mailbox],
      name: 'index_lystonosha_receipts_on_rec_id_rec_type_and_mailbox'
    add_index :lystonosha_receipts, :message_id
  end
end
