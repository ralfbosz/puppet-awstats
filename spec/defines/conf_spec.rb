require 'spec_helper'

describe 'awstats::conf', type: :define do
  on_supported_os.select { |_, facts| facts[:osfamily] == 'RedHat' }.each do |os, facts|
    context "when on #{os}" do
      let(:facts) do
        facts.merge(fqdn: 'foo.example.org',
                    hostname: 'foo')
      end
      let(:title) { 'foo.example.org' }

      context 'with default params' do
        it { is_expected.to contain_awstats__conf('foo.example.org').that_requires('Class[awstats]') }

        it do
          is_expected.to contain_file('/etc/awstats/awstats.foo.example.org.conf').with(
            ensure: 'file',
            owner: 'root',
            group: 'root',
            mode: '0644',
          )
        end
        it do
          is_expected.to contain_file('/etc/awstats/awstats.foo.example.org.conf').with_content(%r{^DirData="/var/lib/awstats"$})
          is_expected.to contain_file('/etc/awstats/awstats.foo.example.org.conf').with_content(%r{^HostAliases="localhost 127.0.0.1 foo"$})
          is_expected.to contain_file('/etc/awstats/awstats.foo.example.org.conf').with_content(%r{^LogFile="/var/log/httpd/access_log"$})
          is_expected.to contain_file('/etc/awstats/awstats.foo.example.org.conf').with_content(%r{^LogFormat=1$})
          is_expected.to contain_file('/etc/awstats/awstats.foo.example.org.conf').with_content(%r{^SiteDomain="foo.example.org"$})
        end
      end

      context 'when template =>' do
        context 'with dne.erb' do
          let(:params) { { template: 'dne.erb' } }

          it 'fails' do
            is_expected.to raise_error(Puppet::Error, %r{Could not find template})
          end
        end

        context 'with []' do
          let(:params) { { template: [] } }

          it 'fails' do
            is_expected.to raise_error(Puppet::Error)
          end
        end
      end

      context 'when options =>' do
        context 'with <add new keys>' do
          let(:params) { { options: { 'foo' => 1, '2' => 'bar' } } }

          it { is_expected.to contain_awstats__conf('foo.example.org').that_requires('Class[awstats]') }

          it do
            is_expected.to contain_file('/etc/awstats/awstats.foo.example.org.conf').with(
              ensure: 'file',
              owner: 'root',
              group: 'root',
              mode: '0644',
            )
          end
          it do
            is_expected.to contain_file('/etc/awstats/awstats.foo.example.org.conf').with_content(%r{^2="bar"$})
            is_expected.to contain_file('/etc/awstats/awstats.foo.example.org.conf').with_content(%r{^DirData="/var/lib/awstats"$})
            is_expected.to contain_file('/etc/awstats/awstats.foo.example.org.conf').with_content(%r{^HostAliases="localhost 127.0.0.1 foo"$})
            is_expected.to contain_file('/etc/awstats/awstats.foo.example.org.conf').with_content(%r{^LogFile="/var/log/httpd/access_log"$})
            is_expected.to contain_file('/etc/awstats/awstats.foo.example.org.conf').with_content(%r{^LogFormat=1$})
            is_expected.to contain_file('/etc/awstats/awstats.foo.example.org.conf').with_content(%r{^SiteDomain="foo.example.org"$})
            is_expected.to contain_file('/etc/awstats/awstats.foo.example.org.conf').with_content(%r{^foo=1$})
          end
        end

        context 'with <replace existing keys>' do
          let(:params) { { options: { 'DirData' => 1, 'LogFormat' => 'bar' } } }

          it { is_expected.to contain_awstats__conf('foo.example.org').that_requires('Class[awstats]') }

          it do
            is_expected.to contain_file('/etc/awstats/awstats.foo.example.org.conf').with(
              ensure: 'file',
              owner: 'root',
              group: 'root',
              mode: '0644',
            )
          end
          it do
            is_expected.to contain_file('/etc/awstats/awstats.foo.example.org.conf').with_content(%r{^DirData=1$})
            is_expected.to contain_file('/etc/awstats/awstats.foo.example.org.conf').with_content(%r{^HostAliases="localhost 127.0.0.1 foo"$})
            is_expected.to contain_file('/etc/awstats/awstats.foo.example.org.conf').with_content(%r{^LogFile="/var/log/httpd/access_log"$})
            is_expected.to contain_file('/etc/awstats/awstats.foo.example.org.conf').with_content(%r{^LogFormat="bar"$})
            is_expected.to contain_file('/etc/awstats/awstats.foo.example.org.conf').with_content(%r{^SiteDomain="foo.example.org"$})
          end
        end

        context 'with <key value is array>' do
          let(:params) { { options: { 'LoadPlugin' => %w[foo bar] } } }

          it { is_expected.to contain_awstats__conf('foo.example.org').that_requires('Class[awstats]') }

          it do
            is_expected.to contain_file('/etc/awstats/awstats.foo.example.org.conf').with(
              ensure: 'file',
              owner: 'root',
              group: 'root',
              mode: '0644',
            )
          end
          it do
            is_expected.to contain_file('/etc/awstats/awstats.foo.example.org.conf').with_content(%r{^DirData="/var/lib/awstats"$})
            is_expected.to contain_file('/etc/awstats/awstats.foo.example.org.conf').with_content(%r{^HostAliases="localhost 127.0.0.1 foo"$})
            is_expected.to contain_file('/etc/awstats/awstats.foo.example.org.conf').with_content(%r{^LoadPlugin="bar"$})
            is_expected.to contain_file('/etc/awstats/awstats.foo.example.org.conf').with_content(%r{^LoadPlugin="foo"$})
            is_expected.to contain_file('/etc/awstats/awstats.foo.example.org.conf').with_content(%r{^LogFile="/var/log/httpd/access_log"$})
            is_expected.to contain_file('/etc/awstats/awstats.foo.example.org.conf').with_content(%r{^LogFormat=1$})
            is_expected.to contain_file('/etc/awstats/awstats.foo.example.org.conf').with_content(%r{^SiteDomain="foo.example.org"$})
          end
        end

        context 'with foo' do
          let(:params) { { options: 'foo' } }

          it 'fails' do
            is_expected.to raise_error(Puppet::Error)
          end
        end
      end
    end
  end
end
