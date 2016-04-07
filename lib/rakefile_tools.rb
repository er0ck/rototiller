module RakefileTools
  def create_rakefile_on(sut, rakefile_contents)
    step 'Copy rake file to SUT' do
      path_to_rakefile = '/root/Rakefile'

      teardown do
        step 'Remove Rakefile on SUT' do
          on(sut, "rm -f #{path_to_rakefile}" )
        end
      end

      create_remote_file(sut, path_to_rakefile, rakefile_contents)
      return path_to_rakefile
    end
  end
end
