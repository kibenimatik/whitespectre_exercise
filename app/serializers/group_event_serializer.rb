class GroupEventSerializer < ApplicationSerializer
  attributes :id, :name, :description, :location, :start_date, :end_date, :duration
end
