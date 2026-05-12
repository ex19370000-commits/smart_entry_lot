class Entry < ApplicationRecord
  belongs_to :user
  belongs_to :event
  belongs_to :shop, optional: true

  enum result: { lose: 0, win: 1 }
  enum status: { unexchanged: 0, exchanged: 1 }

  validate :only_one_entry_per_event, on: :create

  private

  def only_one_entry_per_event
    return if user.nil?

    if user.entries.where(event_id: event_id).exists?
      errors.add(:base, "このイベントへの応募は1回までです")
    end
  end
end
