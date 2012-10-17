require 'devise'

module DeviseExtensions
end

Devise.add_module :approvable, :model => 'devise_extensions/models/approvable'
Devise.add_module :draftable, :model => 'devise_extensions/models/draftable'
Devise.add_module :disableable, :model => 'devise_extensions/models/disableable'