module Types
  module Models
    class UserType < Types::BaseObject
      field :id, ID, null: false
      field :email, String, null: false
      field :avatar, FileType
      field :files, [FileType]
    end
  end
end
