require "log4r"

module VagrantPlugins
  module OpenBSD
    module Action
      # This action reads the state of the machine and puts it in the
      # `:machine_state_id` key in the environment.
      class ReadState
        def initialize(app, env)
          @app    = app
          @logger = Log4r::Logger.new("vagrant_openbsd::action::read_state")
        end

        def call(env)
          env[:machine_state_id] = read_state(env[:machine])

          env[:ui].detail("read_state in action")
          @app.call(env)
        end

        def read_state(machine)
          puts "hello?"
          return :not_created if machine.id.nil?

          # Find the machine
          server = vmctl_exec("status | grep -q #{machine.id}")
          if server.nil? || [:"shutting-down", :terminated].include?(server.state.downcase.to_sym)
            # The machine can't be found
            env[:ui].detail("read_state not found")
            @logger.info("Machine not found or terminated, assuming it got destroyed.")
            machine.id = nil
            return :not_created
          end

          # Return the state
          env[:ui].detail("read_state returning")
          :running
        end
      end
    end
  end
end

