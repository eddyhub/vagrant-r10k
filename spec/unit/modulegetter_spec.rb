require 'spec_helper'

require 'vagrant-r10k/modulegetter'

describe VagrantPlugins::R10k::Modulegetter do 
  include_context 'vagrant-unit'
  let(:test_env) do
    test_env = isolated_environment
    test_env.vagrantfile <<-EOF
Vagrant.configure('2') do |config|
  config.vm.define :test
  # r10k plugin to deploy puppet modules
  # config.r10k.puppet_dir = 'puppet'
  config.r10k.puppetfile_path = 'puppet/Puppetfile'

  # Provision the machine with the appliction
  config.vm.provision "puppet" do |puppet|
    puppet.manifests_path = "puppet/manifests"
    puppet.manifest_file  = "default.pp"
    puppet.module_path = "puppet/modules"
  end
end
EOF
    test_env
  end
  let(:env)              { { env: iso_env, machine: machine, ui: ui, root_path: '/rootpath' } }
  let(:conf)             { Vagrant::Config::V2::DummyConfig.new() }
  let(:ui)               { Vagrant::UI::Basic.new() }
  let(:iso_env)          { test_env.create_vagrant_env ui_class: Vagrant::UI::Basic }
  let(:machine)          { iso_env.machine(:test, :dummy)  }
  # Mock the communicator to prevent SSH commands for being executed.
  let(:communicator)     { double('communicator') }
  # Mock the guest operating system.
  let(:guest)            { double('guest') }
  let(:app)              { lambda { |env| } }
  let(:plugin)           { register_plugin() }
 
  subject { described_class.new(app, env) }

  before (:each) do
    machine.stub(:guest => guest)
    machine.stub(:communicator => communicator)
  end

  #after(:each) { test_env.close }
  
  describe '#call' do
    describe 'puppet_dir unset' do
      it 'should raise an error' do
        expect(ui).to receive(:detail).with("vagrant-r10k: puppet_dir and/or puppetfile_path not set in config; not running").once
        puts ui.methods(true)
        subject.call(env)
      end
    end
  end
  
end
