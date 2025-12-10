require 'spec_helper'

# Shared Specs
#
# Shared specs are meant to aid you splitting up tests that logically belong to a common describe parent into
# multiple files so that there is more fluidity for distributing tests over multiple processes and in particular
# Circle Ci. The aim is to allow splitting up into multiple while not having to repeat test setup logic more than once.
#
# Sometimes usage can best be described via some simple examples...
#
# BASIC USAGE
#
# Let us say you have a single spec file that looks like
#
# describe SomeKlass do
#   let(:a){1}
#   let(:b){2}
#   let(:c){3}
#
#   context 'when pigs fly' do
#     it 'works' do
#       ...
#     end
#   end
#
#   context 'otherwise' do
#     it 'does not work' do
#       ...
#     end
#   end
# end
#
#
# To split it up using this module the convention is to make a shared.rb file in the same directory as the specs. In this
# case the file would look like the following example. The call to run_shared_specs! should be placed wherever you want
# your specs to run.
#
# require 'support/shared_specs'
#
# describe_shared_specs_for(:some_klass) do
#   describe SomeKlass do
#     let(:a){1}
#     let(:b){2}
#     let(:c){3}
#
#     run_shared_specs!
#  end
# end
#
#
# Then for the actual split specs, you'd make two files that look like the following
#
# # first file
# required 'shared.rb'
# shared_specs_for_some_klass do
#   context 'when pigs fly' do
#     it 'works' do
#       ...
#     end
#   end
# end
#
# # second file
# required 'shared.rb'
# shared_specs_for_some_klass do
#   context 'otherwise' do
#     it 'does not work' do
#       ...
#     end
#   end
# end
#
# ADVANCED USAGE
#
# Nested Shared Specs
# In some cases, you might want to split out tests within shared specs themselves. In the below example
#
#
# describe SomeKlass do
#   let(:a){1}
#   let(:b){2}
#   let(:c){3}

#   describe 'pigs' do
#     let(:pig){ create(:pig) }
#     context 'when pigs fly' do
#       it 'works' do
#         ...
#       end
#     end

#     context 'otherwise' do
#       it 'does not work' do
#         ...
#       end
#     end
#   end
#
#   describe 'dogs' do
#     let(:dog){ create(:dog) }
#     context 'when dogs talk' do
#       it 'works' do
#         ...
#       end
#     end
#
#     context 'otherwise' do
#       it 'does not work' do
#         ...
#       end
#     end
#   end
# end
#
# If we want to split out these tests between pigs and dogs, and within each those split them up, we could do the following
#
# first file
# require 'support/shared_specs'
#
# describe_shared_specs_for(:some_klass) do
#   describe SomeKlass do
#     let(:a){1}
#     let(:b){2}
#     let(:c){3}
#
#     run_shared_specs!
#  end
# end
#
# second file
# described_nested_shared_specs_for(:some_klass, :pigs) do
#   describe 'pigs' do
#     let(:pig){ create(:pig) }
#      run_shared_specs!
#   end
# end
#
# third file
# described_nested_shared_specs_for(:some_klass, :dogs) do
#   describe 'dogs' do
#     let(:dog){ create(:dog) }
#     run_shared_specs!
#   end
# end
#
#
# Then our actual spec files would look like
#
# first file
# nested_shared_specs_for_some_klass_pigs do
#   context 'when pigs fly' do
#     it 'works' do
#       ...
#     end
#   end
# end
#
# second file
# nested_shared_specs_for_some_klass_pigs do
#   context 'otherwise' do
#     it 'does not work' do
#       ...
#     end
#   end
# end
#
# third file
# nested_shared_specs_for_some_klass_dogs do
#   context 'when dogs talk' do
#     it 'works' do
#       ...
#     end
#   end
# end
#
# fourth file
# nested_shared_specs_for_some_klass_dogs do
#   context 'otherwise' do
#     it 'does not work' do
#       ...
#     end
#   end
# end

module SharedSpecs
  def run_shared_specs!
    instance_eval(&@@shared_specs)
  end

  def set_shared_specs!(shared_specs)
    @@shared_specs = shared_specs
  end
end

def describe_shared_specs_for(name, &block)
  include SharedSpecs
  define_method("shared_specs_for_#{name}") do |&shared_specs_block|
    set_shared_specs!(shared_specs_block)
    instance_eval(&block)
  end
end

def described_nested_shared_specs_for(parent, nested, &block)
  define_method("nested_shared_specs_for_#{parent}_#{nested}") do |&sub_shared_specs_block|
    send("shared_specs_for_#{parent}") do
      set_shared_specs!(sub_shared_specs_block)
      instance_eval(&block)
    end
  end
end
