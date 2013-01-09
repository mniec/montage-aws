# utils

module MontageAWS


autoload :Cmd, 'montage_aws/utils/cmd'
autoload :MontageHelper, 'montage_aws/utils/montage_helper'

# factories
autoload :Tasks, 'montage_aws/factory/tasks'

autoload :CmdTask, 'montage_aws/tasks/cmd/cmd_task'

# cmd
autoload :Provision, 'montage_aws/tasks/cmd/provision'
autoload :Worker, 'montage_aws/tasks/cmd/worker'
autoload :InfrastructureProvisioner, 'montage_aws/tasks/cmd/infrastructure_provisioner'
autoload :Decider, 'montage_aws/tasks/cmd/decider'
autoload :Compute, 'montage_aws/tasks/cmd/compute'

# activities
autoload :Project, 'montage_aws/tasks/activities/project'
autoload :Merge, 'montage_aws/tasks/activities/merge'
autoload :StartEc2, 'montage_aws/tasks/activities/start_ec2'
autoload :StartEC2InfrastructureProvisioner, 'montage_aws/tasks/activities/start_ec2'
autoload :StartEC2Worker, 'montage_aws/tasks/activities/start_ec2'
autoload :StartEC2Worker, 'montage_aws/tasks/activities/start_ec2'
autoload :StartEC2Decider, 'montage_aws/tasks/activities/start_ec2'

end