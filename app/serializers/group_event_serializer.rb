class GroupEventSerializer < ApplicationSerializer
  attributes :id, :name, :description, :location, :start_date, :end_date, :duration

  def duration
    object.duration if object.duration?
  end
end
