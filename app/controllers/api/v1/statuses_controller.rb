# frozen_string_literal: true

module Api
  module V1
    class StatusesController < ApplicationController
      def show
        render json: { git_sha: git_sha }
      end

      private

        def git_sha
          git_sha = `cat .git/HEAD | awk '{ print $2 }'\
                      | xargs -I % sh -c 'cat .git/%'`.strip
          git_sha.presence || `cat .git/HEAD`.strip
        end
    end
  end
end
