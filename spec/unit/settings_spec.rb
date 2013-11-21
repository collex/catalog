require 'spec_helper'

describe "Settings" do
  let(:test_home) { File.expand_path("~") }
  
  it { Settings.site_name_title.should == "Arc Catalog" }
  it { Settings.project_manager_email.should == "manager example com" }

  context "paperclip" do
    it { Settings.paperclip.image_magic_path.should == "/usr/bin" }
  end

  context "admin" do
    it { Settings.admin.email.should == "vicky@performantsoftware.com" }
  end
  
  context "exception_notifier" do
    it { Settings.exception_notifier.exception_recipients.should == ["root@localhost"] }
    it { Settings.exception_notifier.sender_address.should == '"Arc Catalog" <arc@localhost>' }
    it { Settings.exception_notifier.email_prefix.should == "[Project] " }
  end

  context "smtp_settings" do
    it { Settings.smtp_settings.address.should == "smtp.gmail.com" }
    it { Settings.smtp_settings.port.should == 587 }
    it { Settings.smtp_settings.user_name.should == 'admin@example.com' }
    it { Settings.smtp_settings.password.should == 'super-secret' }
    it { Settings.smtp_settings.authentication.should == :plain }
    it { Settings.smtp_settings.return_path.should == "http://example.com" }
    it { Settings.smtp_settings.enable_starttls_auto.should == true }
    it { Settings.smtp_settings.xsmtpapi.should == 'catalog' }
    it { Settings.smtp_settings.domain.should == 'catalog.ar-c.org' }
  end

  context "folders" do
    it { Settings.folders.rdf.should == "#{test_home}/rdf" }
    it { Settings.folders.marc.should == "#{test_home}/marc" }
    it { Settings.folders.ecco.should == "#{test_home}/ecco" }
    it { Settings.folders.rdf_indexer.should == "#{test_home}/rdf-indexer" }
    it { Settings.folders.backups.should == "#{test_home}/backups" }
    it { Settings.folders.uploaded_data.should == "#{test_home}/uploaded_data" }
    it { Settings.folders.tasks_send_method.should == "scp" }
    it { Settings.folders.tamu_key.should == 'private-token' }
  end

  context "production" do
    it { Settings.production.ssh_user.should == "nines" }
    it { Settings.production.ssh_host.should == "arc.performantsoftware.com" }
  end

  context "capistrano" do
    context "edge" do
      it { Settings.capistrano.edge.user.should == "arc" }
      it { Settings.capistrano.edge.ssh_name.should == "ssh-name-to-login-to-server" }
      it { Settings.capistrano.edge.ruby.should == "ruby-1.9.3-p374@catalog" }
      it { Settings.capistrano.edge.system_rvm.should == false }
      it { Settings.capistrano.edge.deploy_base.should == "/home/arc/www" }
    end
    
    context "prod" do
      it { Settings.capistrano.prod.user.should == "arc" }
      it { Settings.capistrano.prod.ssh_name.should == "ssh-name-to-login-to-server" }
      it { Settings.capistrano.prod.ruby.should == "ruby-1.9.3-p374@catalog" }
      it { Settings.capistrano.prod.system_rvm.should == false }
      it { Settings.capistrano.prod.deploy_base.should == "/home/arc/www" }
    end
  end
end
