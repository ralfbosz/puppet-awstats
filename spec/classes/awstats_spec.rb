require 'spec_helper'

describe 'awstats' do
  context 'with supported operating systems' do
    on_supported_os.each do |os, facts|
      context "when on #{os}" do
        let(:facts) do
          facts
        end

        context 'with default params' do
          it { is_expected.to contain_package('awstats') }

          it do
            is_expected.to contain_file('/etc/awstats').with(
              ensure: 'directory',
              owner: 'root',
              group: 'root',
              mode: '0755',
              recurse: true,
              purge: false,
            )
          end
          it { is_expected.to contain_file('/etc/awstats').that_requires('Package[awstats]') }
        end

        context 'when config_dir_purge =>' do
          context 'with true' do
            let(:params) { { config_dir_purge: true } }

            it { is_expected.to contain_package('awstats') }

            it do
              is_expected.to contain_file('/etc/awstats').with(
                ensure: 'directory',
                owner: 'root',
                group: 'root',
                mode: '0755',
                recurse: true,
                purge: true,
              )
            end
            it { is_expected.to contain_file('/etc/awstats').that_requires('Package[awstats]') }
          end

          context 'with false' do
            let(:params) { { config_dir_purge: false } }

            it { is_expected.to contain_package('awstats') }

            it do
              is_expected.to contain_file('/etc/awstats').with(
                ensure: 'directory',
                owner: 'root',
                group: 'root',
                mode: '0755',
                recurse: true,
                purge: false,
              )
            end
            it { is_expected.to contain_file('/etc/awstats').that_requires('Package[awstats]') }
          end

          context 'with 42' do
            let(:params) { { config_dir_purge: 42 } }

            it 'fails' do
              is_expected.to raise_error(Puppet::Error)
            end
          end
        end

        context 'when enable_plugins =>' do
          context "with [ 'decodeutfkeys' ]" do
            let(:params) { { enable_plugins: ['decodeutfkeys'] } }

            case facts[:osfamily]
            when 'Debian'
              it { is_expected.to contain_package('liburi-perl') }
            when 'RedHat'
              it { is_expected.to contain_package('perl-URI') }
            end

            it do
              is_expected.to contain_class('awstats::plugin::decodeutfkeys')
                .that_comes_before('Anchor[awstats::end]')
            end
          end

          context "with [ 'geoip' ]" do
            let(:params) { { enable_plugins: ['geoip'] } }

            case facts[:osfamily]
            when 'Debian'
              it { is_expected.to contain_package('libgeo-ip-perl') }
            when 'RedHat'
              it { is_expected.to contain_package('perl-Geo-IP') }
            end

            it do
              is_expected.to contain_class('awstats::plugin::geoip')
                .that_comes_before('Anchor[awstats::end]')
            end
          end

          # check case insensitivity and multiple enable_plugins
          context "with [ 'DECODEUTFKEYS', 'GEOIP' ]" do
            let(:params) { { enable_plugins: %w[DECODEUTFKEYS GEOIP] } }

            case facts[:osfamily]
            when 'Debian'
              it { is_expected.to contain_package('liburi-perl') }
              it { is_expected.to contain_package('libgeo-ip-perl') }
            when 'RedHat'
              it { is_expected.to contain_package('perl-URI') }
              it { is_expected.to contain_package('perl-Geo-IP') }
            end
          end

          context 'with 42' do
            let(:params) { { enable_plugins: 42 } }

            it 'fails' do
              is_expected.to raise_error(Puppet::Error)
            end
          end
        end
      end
    end

    context 'when el5.x' do
      let(:facts) do
        { 'os' => { 'name' => 'RedHat', 'family' => 'RedHat', 'release' => { 'major' => '5', 'minor' => '11', 'full' => '5.11' } } }
      end

      it 'fails' do
        is_expected.to raise_error(Puppet::Error, %r{is not supported on RedHat 5})
      end
    end

    context 'when el8.x' do
      let(:facts) do
        { 'os' => { 'name' => 'RedHat', 'family' => 'RedHat', 'release' => { 'major' => '8', 'minor' => '0', 'full' => '8.0' } } }
      end

      it 'fails' do
        is_expected.to raise_error(Puppet::Error, %r{is not supported on RedHat 8})
      end
    end
  end

  context 'when on osfamily Solaris' do
    let(:facts) do
      { 'os' => { 'name' => 'Solaris', 'family' => 'Solaris', 'release' => { 'major' => '8', 'minor' => '6', 'full' => '8.6' } } }
    end

    it 'fails' do
      is_expected.to raise_error(Puppet::Error, %r{is not supported on Solaris})
    end
  end
end
