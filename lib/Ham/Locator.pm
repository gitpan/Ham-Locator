#!/usr/bin/perl

#=======================================================================
# Locator.pm / Ham::Locator
# $Id: Locator.pm 4 2010-12-17 20:55:07Z andys $
# $HeadURL: https://daedalus.dmz.dn7.org.uk/svn/Ham-Locator/lib/Ham/Locator.pm $
# (c)2010 Andy Smith <andy.smith@nsnw.co.uk>
#-----------------------------------------------------------------------
#:Description
# Module to easily convert between Maidenhead locators and coordinates
# in latitude and longitude format.
#-----------------------------------------------------------------------
#:Synopsis
#
# use Ham::Locator;
# my $m = new Ham::Locator;
# $m->set_loc('IO93lo');
# my ($latitude, $longitude) = $m->loc2latlng;
#=======================================================================
#
# With thanks to http://home.arcor.de/waldemar.kebsch/The_Makrothen_Contest/fmaidenhead.js
#

# The pod (Perl documentation) for this module is provided inline. For a
# better-formatted version, please run:-
# $ perldoc Locator.pm

=head1 NAME

Ham::Locator - Convert between Maidenhead locators and latitude/longitude.

=head1 SYNOPSIS

  use Ham::Locator;
  my $m = new Ham::Locator;
  $m->set_loc('IO93lo');
  my ($latitude, $longitude) = $m->loc2latlng;

=head1 DEPENDENCIES

=over4

=item * Carp - for error handling

=item * Class::Accessor - for accessor method generation

=back

=cut

# Module setup
package Ham::Locator;

use strict;
use warnings;

our $VERSION = '0.001';

# Module inclusion
use Carp;
use Data::Dumper;

# Set up accessor methods with Class::Accessor
use base qw(Class::Accessor);
__PACKAGE__->follow_best_practice;
__PACKAGE__->mk_accessors( qw(loc lnglat) );

=head1 CONSTRUCTORS

=head2 Locator->new

Creates a new C<Ham::Locator> object.

=head1 ACCESSORS 

=head2 $locator->set_loc(I<locator>)

Sets the locator to use for conversion to latitude and longitude.

=cut

sub l2n
{
	my ($self, $letter) = @_;

	my $lw = lc $letter;

	my $index = {	'a' => 0,
					'b' => 1,
					'c' => 2,
					'd' => 3,
					'e' => 4,
					'f' => 5,
					'g' => 6,
					'h' => 7,
					'i' => 8,
					'j' => 9,
					'k' => 10,
					'l' => 11,
					'm' => 12,
					'n' => 13,
					'o' => 14,
					'p' => 15,
					'q' => 16,
					'r' => 17,
					's' => 18,
					't' => 19,
					'u' => 20,
					'v' => 21,
					'w' => 22,
					'x' => 23
	};

	return $index->{$lw};
};

sub n2l
{
	my ($self, $number) = @_;

	my $index = {	0 => 'a',
					1 => 'b',
					2 => 'c',
					3 => 'd',
					4 => 'e',
					5 => 'f',
					6 => 'g',
					7 => 'h',
					8 => 'i',
					9 => 'j',
					10 => 'k',
					11 => 'l',
					12 => 'm',
					13 => 'n',
					14 => 'o',
					15 => 'p',
					16 => 'q',
					17 => 'r',
					18 => 's',
					19 => 't',
					20 => 'u',
					21 => 'v',
					22 => 'w',
					23 => 'x'
	};

	return $index->{$number};
};

=head1 METHODS

=head2 $locator->loc2latlng

Converts the locator set by B<set_loc> to latitude and longitude, and returns them as an array of two values.

=cut

sub loc2latlng
{
	my ($self) = @_;

	if($self->get_loc eq "")
	{
		return 0;
	}

	my $loc = $self->get_loc;
	my $useSubsquare;

	if(length $loc eq 4)
	{
		$loc = $loc . "MM";
		$useSubsquare = 0;
	}
	elsif(length $loc ne 6)
	{
		return 0;
	}
	else
	{
		$useSubsquare = 1;
	}

	my $field_x		= substr $loc, 0, 1;
	my $field_y		= substr $loc, 1, 1;
	my $square_x	= substr $loc, 2, 1;
	my $square_y	= substr $loc, 3, 1;
	my $subsq_x		= substr $loc, 4, 1;
	my $subsq_y		= substr $loc, 5, 1;

	my $field_x_n = $self->l2n($field_x);
	my $field_y_n = $self->l2n($field_y);
	my $subsq_x_n = $self->l2n($subsq_x);
	my $subsq_y_n = $self->l2n($subsq_y);

	my $calc_field_x = $field_x_n*10 + $square_x + ($subsq_x_n/24);
	if($useSubsquare eq 1)
	{
		$calc_field_x = $calc_field_x + (1/48);
	}
	$calc_field_x = $calc_field_x * 2;
	$calc_field_x = $calc_field_x - 180;

	my $calc_field_y = $field_y_n*10 + $square_y + ($subsq_y_n/24);
	if($useSubsquare eq 1)
	{
		$calc_field_y = $calc_field_y + (1/48);
	}
	$calc_field_y = $calc_field_y - 90;

	return "$calc_field_x $calc_field_y";
};

=head1 CAVEATS

The obvious latlng2loc doesn't exist yet. This module was written to serve a specific purpose, so hopefully I'll be adding this shortly.

=head1 BUGS

=item1 * None, other than what's already been mentioned under B<CAVEATS>.

This module was written by B<Andy Smith> <andy.smith@netprojects.org.uk>.

=head1 COPYRIGHT

$Id: Locator.pm 4 2010-12-17 20:55:07Z andys $

(c)2009 Andy Smith (L<http://andys.org.uk/>)

This library is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

=cut

1;
