require 'spec_helper'

describe 'puppet_device' do
  context 'declared on a device' do
    let(:title)  { 'bigip.example.com' }
    let(:params) do
      {
        :ensure       => :present,
        :type         => 'f5',
        :url          => 'https://admin:fffff55555@10.0.0.245/',
        :debug        => true,
      }
    end
    let(:facts) do
      {
        :os => { :family => 'cisco-ios-xe' },
      }
    end

    it { is_expected.to raise_error(%r{declared on a device}) }
  end

  context 'declared on Linux, running Puppet 5.0, with values for all device.conf parameters' do
    let(:title)  { 'bigip.example.com' }
    let(:params) do
      {
        :ensure       => :present,
        :type         => 'f5',
        :url          => 'https://admin:fffff55555@10.0.0.245/',
        :debug        => true,
      }
    end
    let(:facts) do
      {
        :aio_agent_version            => '5.0.0',
        :puppetversion                => '5.0.0',
        :puppet_settings_deviceconfig => '/etc/puppetlabs/puppet/device.conf',
        :puppet_settings_confdir      => '/etc/puppetlabs',
        :os                           => { :family => 'redhat' },
      }
    end

    it { is_expected.to contain_puppet_device('bigip.example.com') }
    it { is_expected.to contain_class('puppet_device::conf') }
    it { is_expected.to contain_class('puppet_device::fact') }
  end

  context 'declared on Windows, running Puppet 5.0, with values for all device.conf parameters' do
    let(:title)  { 'bigip.example.com' }
    let(:params) do
      {
        :ensure       => :present,
        :type         => 'f5',
        :url          => 'https://admin:fffff55555@10.0.0.245/',
        :debug        => true,
      }
    end
    let(:facts) do
      {
        :aio_agent_version            => '5.0.0',
        :puppetversion                => '5.0.0',
        :puppet_settings_deviceconfig => 'C:/ProgramData/PuppetLabs/puppet/etc/device.conf',
        :puppet_settings_confdir      => 'C:/ProgramData/PuppetLabs/puppet',
        :os                           => { :family => 'windows' },
        :env_windows_installdir       => 'C:\\Program Files\\Puppet Labs\\Puppet',
      }
    end

    it { is_expected.to contain_puppet_device('bigip.example.com') }
    it { is_expected.to contain_class('puppet_device::conf') }
    it { is_expected.to contain_class('puppet_device::fact') }
  end

  context 'declared on Linux, running Puppet 4.10, with run_interval' do
    let(:title)  { 'bigip.example.com' }
    let(:params) do
      {
        :ensure       => :present,
        :type         => 'f5',
        :url          => 'https://admin:fffff55555@10.0.0.245/',
        :run_interval => 30,
      }
    end
    let(:facts) do
      {
        :aio_agent_version            => '4.10.0',
        :puppetversion                => '4.10.0',
        :puppet_settings_deviceconfig => '/etc/puppetlabs/puppet/device.conf',
        :puppet_settings_confdir      => '/etc/puppetlabs',
        :os                           => { :family => 'redhat' },
      }
    end

    it { is_expected.to contain_puppet_device('bigip.example.com') }
    it { is_expected.to contain_class('puppet_device::conf') }
    it { is_expected.to contain_class('puppet_device::fact') }
    it { is_expected.to contain_puppet_device__run__via_cron__device('bigip.example.com') }
    it {
      is_expected.to contain_cron('run puppet_device').with(
        'command' => '/opt/puppetlabs/puppet/bin/puppet device --waitforcert=0 --user=root --verbose',
      )
    }
  end

  context 'declared on Linux, running Puppet 5.0, with run_interval' do
    let(:title)  { 'bigip.example.com' }
    let(:params) do
      {
        :ensure       => :present,
        :type         => 'f5',
        :url          => 'https://admin:fffff55555@10.0.0.245/',
        :run_interval => 30,
      }
    end
    let(:facts) do
      {
        :aio_agent_version            => '5.0.0',
        :puppetversion                => '5.0.0',
        :puppet_settings_deviceconfig => '/etc/puppetlabs/puppet/device.conf',
        :puppet_settings_confdir      => '/etc/puppetlabs',
        :os                           => { :family => 'redhat' },
      }
    end

    it { is_expected.to contain_puppet_device('bigip.example.com') }
    it { is_expected.to contain_class('puppet_device::conf') }
    it { is_expected.to contain_class('puppet_device::fact') }
    it { is_expected.to contain_puppet_device__run__via_cron__device('bigip.example.com') }
    it {
      is_expected.to contain_cron('run puppet_device target bigip.example.com').with(
        'command' => '/opt/puppetlabs/puppet/bin/puppet device --waitforcert=0 --user=root --verbose --target=bigip.example.com',
        'hour'    => '*',
        'minute'  => %w[11 41],
      )
    }
  end

  context 'declared on Windows, running Puppet 5.0, with run_interval' do
    let(:title)  { 'bigip.example.com' }
    let(:params) do
      {
        :ensure       => :present,
        :type         => 'f5',
        :url          => 'https://admin:fffff55555@10.0.0.245/',
        :run_interval => 30,
      }
    end
    let(:facts) do
      {
        :aio_agent_version            => '5.0.0',
        :puppetversion                => '5.0.0',
        :puppet_settings_deviceconfig => 'C:/ProgramData/PuppetLabs/puppet/etc/device.conf',
        :puppet_settings_confdir      => 'C:/ProgramData/PuppetLabs/puppet',
        :os                           => { :family => 'windows' },
        :env_windows_installdir       => 'C:\\Program Files\\Puppet Labs\\Puppet',
      }
    end

    it { is_expected.to contain_puppet_device('bigip.example.com') }
    it { is_expected.to contain_class('puppet_device::conf') }
    it { is_expected.to contain_class('puppet_device::fact') }
    it { is_expected.to contain_puppet_device__run__via_scheduled_task__device('bigip.example.com') }
    it {
      is_expected.to contain_scheduled_task('run puppet_device target bigip.example.com').with(
        'command' => 'C:\\Program Files\\Puppet Labs\\Puppet\\bin\\puppet',
      )
    }
  end

  # The puppet command is quoted in this Exec to support spaces in the path on Windows.

  context 'declared on Linux, running Puppet 5.0, with run_via_exec' do
    let(:title)  { 'bigip.example.com' }
    let(:params) do
      {
        :ensure       => 'present',
        :type         => 'f5',
        :url          => 'https://admin:fffff55555@10.0.0.245/',
        :run_via_exec => true,
      }
    end
    let(:facts) do
      {
        :aio_agent_version            => '5.0.0',
        :puppetversion                => '5.0.0',
        :puppet_settings_deviceconfig => '/etc/puppetlabs/puppet/device.conf',
        :puppet_settings_confdir      => '/etc/puppetlabs',
        :os                           => { :family => 'redhat' },
      }
    end

    it { is_expected.to contain_puppet_device('bigip.example.com') }
    it { is_expected.to contain_class('puppet_device::conf') }
    it { is_expected.to contain_class('puppet_device::fact') }
    it { is_expected.to contain_puppet_device__run__via_exec__device('bigip.example.com') }
    it {
      is_expected.to contain_exec('run puppet_device target bigip.example.com').with(
        'command' => '"/opt/puppetlabs/puppet/bin/puppet" device --waitforcert=0 --user=root --verbose --target=bigip.example.com',
      )
    }
  end

  context 'declared on Linux, running Puppet 5.0, with run_interval and run_via_exec parameters' do
    let(:title)  { 'bigip.example.com' }
    let(:params) do
      {
        :ensure       => :present,
        :type         => 'f5',
        :url          => 'https://admin:fffff55555@10.0.0.245/',
        :run_interval => 30,
        :run_via_exec => true,
      }
    end
    let(:facts) do
      {
        :aio_agent_version            => '5.0.0',
        :puppetversion                => '5.0.0',
        :puppet_settings_deviceconfig => '/etc/puppetlabs/puppet/device.conf',
        :puppet_settings_confdir      => '/etc/puppetlabs',
        :os                           => { :family => 'redhat' },
      }
    end

    it { is_expected.to raise_error(%r{are mutually-exclusive}) }
  end
end
