# frozen_string_literal: true

Sequel.migration do
  transaction
  change do
    create_table(:locations) do
      String :locode, size: 20, primary_key: true
      String :country_code, size: 2
      String :identifier, size: 3
      String :change, size: 4, default: nil
      String :name, size: 200, null: false
      String :name_without_diacritics, size: 200, null: false
      String :subdiv, size: 6, default: nil
      String :status, size: 2, default: nil
      Date :date
      String :iata, size: 3, default: nil
      String :remarks, size: 200, default: nil
      Point :location, null: false
    end

    alter_table(:locations) do
      add_spatial_index :location
    end

    create_table(:functions) do
      primary_key :id
      foreign_key :locode, :locations, type: String, size: 20
      String :function, size: 15
    end
  end
end
