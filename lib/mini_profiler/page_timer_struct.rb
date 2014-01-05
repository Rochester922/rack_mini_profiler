require 'mini_profiler/timer_struct'

module Rack
  class MiniProfiler

    # PageTimerStruct
    #   Root: RequestTimer
    #     :has_many RequestTimer children
    #     :has_many SqlTimer children
    #     :has_many CustomTimer children
    class PageTimerStruct < TimerStruct
      def initialize(env)
        super(:id => MiniProfiler.generate_id,
              :name => env['PATH_INFO'],
              :started => (Time.now.to_f * 1000).to_i,
              :machine_name => env['SERVER_NAME'],
              :level => 0,
              :user => "unknown user",
              :has_user_viewed => false,
              :client_timings => nil,
              :duration_milliseconds => 0,
              :has_trivial_timings => true,
              :has_all_trivial_timings => false,
              :trivial_duration_threshold_milliseconds => 2,
              :head => nil,
              :duration_milliseconds_in_sql => 0,
              :has_sql_timings => true,
              :has_duplicate_sql_timings => false,
              :executed_readers => 0,
              :executed_scalars => 0,
              :executed_non_queries => 0,
              :custom_timing_names => [],
              :custom_timing_stats => {}
             )
        name = "#{env['REQUEST_METHOD']} http://#{env['SERVER_NAME']}:#{env['SERVER_PORT']}#{env['SCRIPT_NAME']}#{env['PATH_INFO']}"
        self[:root] = RequestTimerStruct.create_root(name, self)
      end

      def duration_ms
        @attributes[:root][:duration_milliseconds]
      end

      def root
        @attributes[:root]
      end

      def to_json(*a)
        attribs = @attributes.merge(
          :started => '/Date(%d)/' % @attributes[:started],
          :duration_milliseconds => @attributes[:root][:duration_milliseconds],
          :custom_timing_names => @attributes[:custom_timing_stats].keys.sort
        )
        ::JSON.generate(attribs, :max_nesting => 100)
      end
    end

  end
end
