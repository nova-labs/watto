# frozen_string_literal: true

class Admin::BaseController < ApplicationController
  before_action :require_signoffer

end
