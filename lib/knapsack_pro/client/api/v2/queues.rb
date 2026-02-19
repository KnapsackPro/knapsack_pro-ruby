# frozen_string_literal: true

module KnapsackPro
  module Client
    module API
      module V2
        class Queues < KnapsackPro::Client::API::V1::Base
          CODE_ATTEMPT_CONNECT_TO_QUEUE_FAILED = 'ATTEMPT_CONNECT_TO_QUEUE_FAILED'

          class << self
            def queue(args)
              request_hash = {
                attempt_connect_to_queue: args.fetch(:attempt_connect_to_queue),
                batch_uuid: SecureRandom.uuid,
                batch_index: args.fetch(:batch_uuid),
                branch: args.fetch(:branch),
                can_initialize_queue: args.fetch(:can_initialize_queue),
                commit_hash: args.fetch(:commit_hash),
                fixed_queue_split: KnapsackPro::Config::Env.fixed_queue_split_?,
                node_index: args.fetch(:node_index),
                node_total: args.fetch(:node_total),
                node_uuid: KnapsackPro::Config::Env.node_uuid,
                test_queue_id: KnapsackPro::Config::Env.test_queue_id,
                user_seat: KnapsackPro::Config::Env.masked_user_seat
              }

              if request_hash[:can_initialize_queue] && !request_hash[:attempt_connect_to_queue]
                git_adapter = KnapsackPro::RepositoryAdapters::GitAdapter.new

                request_hash.merge!(
                  build_author: git_adapter.build_author,
                  commit_authors: git_adapter.commit_authors,
                  test_files: args.fetch(:test_files)
                )
              end

              if !request_hash[:can_initialize_queue] && !request_hash[:attempt_connect_to_queue]
                request_hash.merge!(
                  failed_paths: args.fetch(:failed_paths)
                )
              end

              action_class.new(
                endpoint_path: '/v2/queues/queue',
                http_method: :post,
                request_hash: request_hash
              )
            end

            def connect
              git_adapter = KnapsackPro::RepositoryAdapters::GitAdapter.new
              repository_adapter = KnapsackPro::RepositoryAdapterInitiator.call

              request_hash = {
                attempt_connect_to_queue: true,
                batch_uuid: SecureRandom.uuid,
                batch_index: 0,
                branch: KnapsackPro::Crypto::BranchEncryptor.call(repository_adapter.branch),
                build_author: git_adapter.build_author,
                can_initialize_queue: true,
                commit_authors: git_adapter.commit_authors,
                commit_hash: repository_adapter.commit_hash,
                fixed_queue_split: KnapsackPro::Config::Env.fixed_queue_split_?,
                node_index: KnapsackPro::Config::Env.ci_node_index,
                node_total: KnapsackPro::Config::Env.ci_node_total,
                node_uuid: SecureRandom.uuid,
                skip_pull: true,
                test_queue_id: KnapsackPro::Config::Env.test_queue_id,
                user_seat: KnapsackPro::Config::Env.masked_user_seat,
              }

              action_class.new(
                endpoint_path: '/v2/queues/queue',
                http_method: :post,
                request_hash: request_hash
              )
            end

            def initialize(paths)
              git_adapter = KnapsackPro::RepositoryAdapters::GitAdapter.new
              repository_adapter = KnapsackPro::RepositoryAdapterInitiator.call

              request_hash = {
                attempt_connect_to_queue: false,
                batch_uuid: SecureRandom.uuid,
                batch_index: 0,
                branch: KnapsackPro::Crypto::BranchEncryptor.call(repository_adapter.branch),
                build_author: git_adapter.build_author,
                can_initialize_queue: true,
                commit_authors: git_adapter.commit_authors,
                commit_hash: repository_adapter.commit_hash,
                fixed_queue_split: KnapsackPro::Config::Env.fixed_queue_split_?,
                node_index: KnapsackPro::Config::Env.ci_node_index,
                node_total: KnapsackPro::Config::Env.ci_node_total,
                node_uuid: SecureRandom.uuid,
                skip_pull: true,
                test_files: KnapsackPro::Crypto::Encryptor.call(paths),
                test_queue_id: KnapsackPro::Config::Env.test_queue_id,
                user_seat: KnapsackPro::Config::Env.masked_user_seat,
              }

              action_class.new(
                endpoint_path: '/v2/queues/queue',
                http_method: :post,
                request_hash: request_hash
              )
            end
          end
        end
      end
    end
  end
end
