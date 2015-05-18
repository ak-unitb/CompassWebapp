json.array!(@people) do |person|
  json.extract! person, :id, :firstname, :middlename, :lastname, :title, :sex, :salutation, :password, :roles, :status
  json.url person_url(person, format: :json)
end
