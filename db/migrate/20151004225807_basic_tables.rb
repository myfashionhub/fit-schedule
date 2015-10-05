class BasicTables < ActiveRecord::Migration
  def change

    create_table :users do |t|
      t.string :name
      t.string :email
      t.string :image
      t.string :google_uid
      t.string :google_token
      t.text   :availability
      t.string :zipcode
      t.timestamps
    end

    create_table :filters do |t|
      t.string   :class_type
      t.string   :class_level
      t.references :users, index: true
      t.timestamps
    end

    create_table :appointments do |t|
      t.integer    :reminder # number of minutes prior to appt
      t.references :users, index: true
      t.references :classes, index: true
      t.timestamps
    end

    create_table :classes do |t|
      t.string   :type
      t.string   :level   
      t.datetime :start_time
      t.datetime :end_time
      t.integer  :duration
      t.datetime :date
      t.references :studios, index: true
      t.timestamps
    end

    create_table :studios do |t|
      t.string   :name
      t.string   :address
      t.string   :schedule_url
      t.string   :logo
      t.timestamps
    end

  end
end
