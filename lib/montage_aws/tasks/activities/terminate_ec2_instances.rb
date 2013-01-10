require 'socket'

module MontageAWS

  class TerminateEc2Instances < ActivityTask
    include EC2Utils

    def initialize task, params
      super
      init_EC2 params
    end

    def execute
      current_machine = nil 
      @ec2.instances.each  do |i|
        if is_current(i)
          current_machine = i
        else
          i.terminate() if instance_valid?(i)
        end 
      end 
      current_machine.terminate unless current_machine.nil?
    end

    private 

    def is_current instance
      return instance.ip_address == my_first_public_ipv4
    end 

    def my_first_public_ipv4
      Socket.ip_address_list.detect{|intf| intf.ipv4? and !intf.ipv4_loopback? and !intf.ipv4_multicast? and !intf.ipv4_private?}
    end
  end
end