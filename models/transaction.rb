# Copyright © 2017, ACM@UIUC
#
# This file is part of the Groot Project.
#
# The Groot Project is open source software, released under the University of
# Illinois/NCSA Open Source License. You should have received a copy of
# this license in a file with the distribution.

class Transaction
  include DataMapper::Resource

  property :id, Serial
  property :created_on, Date
  belongs_to :user
  has n, :items, through: Resource

  def amount
    items.map(&:price).reduce(:+)
  end

  def serialize
    {
      id: id,
      user: user.serialize,
      items: items.map(&:serialize),
      cost: amount,
      created_on: created_on
    }
  end
end
