# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120620120026) do

  create_table "lystonosha_conversations", :force => true do |t|
    t.string   "subject",    :limit => 200
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  create_table "lystonosha_messages", :force => true do |t|
    t.string   "subject",         :limit => 200
    t.text     "body"
    t.integer  "sender_id"
    t.string   "sender_type"
    t.integer  "conversation_id",                :null => false
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
  end

  add_index "lystonosha_messages", ["conversation_id"], :name => "index_lystonosha_messages_on_conversation_id"

  create_table "lystonosha_receipts", :force => true do |t|
    t.integer "recipient_id",                                    :null => false
    t.string  "recipient_type",                                  :null => false
    t.integer "message_id",                                      :null => false
    t.boolean "read",                         :default => false
    t.string  "mailbox",        :limit => 10
  end

  add_index "lystonosha_receipts", ["message_id"], :name => "index_lystonosha_receipts_on_message_id"
  add_index "lystonosha_receipts", ["recipient_id", "recipient_type", "mailbox"], :name => "index_lystonosha_receipts_on_rec_id_rec_type_and_mailbox"

  create_table "users", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

end
