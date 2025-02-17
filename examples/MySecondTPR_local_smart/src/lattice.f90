!  This file was generated by kmcos (kinetic Monte Carlo of Systems)
!  written by Max J. Hoffmann mjhoffmann@gmail.com (C) 2009-2013.
!  The model was written by Max J. Hoffmann.

!  This file is part of kmcos.
!
!  kmcos is free software; you can redistribute it and/or modify
!  it under the terms of the GNU General Public License as published by
!  the Free Software Foundation; either version 2 of the License, or
!  (at your option) any later version.
!
!  kmcos is distributed in the hope that it will be useful,
!  but WITHOUT ANY WARRANTY; without even the implied warranty of
!  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!  GNU General Public License for more details.
!
!  You should have received a copy of the GNU General Public License
!  along with kmcos; if not, write to the Free Software
!  Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301
!  USA
!****h* kmcos/lattice
! FUNCTION
!    Implements the mappings between the real space lattice
!    and the 1-D lattice, which kmcos/base operates on.
!    Furthermore replicates all geometry specific functions of kmcos/base
!    in terms of lattice coordinates.
!    Using this module each site can be addressed with 4-tuple
!    ``(i, j, k, n)`` where ``i, j, k`` define the unit cell and
!    ``n`` the site within the unit cell.
!
!******


module lattice
use kind_values
use base, only: &
    assertion_fail, &
    base_deallocate_system => deallocate_system, &
    get_kmc_step, &
    get_kmc_time, &
    get_kmc_time_step, &
    get_rate, &
    increment_procstat, &
    base_add_proc => add_proc, &
    base_reset_site => reset_site, &
    base_allocate_system => allocate_system, &
    base_can_do => can_do, &
    base_del_proc => del_proc, &
    determine_procsite, &
    base_replace_species => replace_species, &
    base_get_species => get_species, &
    base_get_volume => get_volume, &
    reload_system => reload_system, &
    save_system, &
    assertion_fail, &
    set_rate_const, &
    update_accum_rate, &
    update_clocks



implicit none

integer(kind=iint), dimension(3), public :: system_size
!****v* lattice/system_size
! FUNCTION
!   Stores the current size of the allocated system lattice (x, y, z)
!   in an integer array. In low-dimensional system, corresponding entries will be set to 1.
!   Note that this should be thought of as a read-only variable. Changing its value at model
!   runtime will not the indented effect of actually changing the simulated lattice.
!   The definitive location for custom lattice size is `simulation_size` in `kmc_settings.py`.
!
!   If the system size shall be changed programmatically, it needs to happen before the `KMC_Model`
!   is instantiated and Fortran array are allocated accordingly, like to
!
!       #!/usr/bin/env python3
!
!       import kmc_settings
!       import kmcos.run
!
!       kmc_settings.simulation_size = 9, 9, 4
!
!       with kmcos.run.KMC_Model() as model:
!           print(model.lattice.system_size)))`
!
!******
integer(kind=iint), parameter, public :: nr_of_layers = 1
!****v* lattice/nr_of_layers
! FUNCTION
!   Constant storing the number of layers (for multi-lattice models > 1)
!******

 ! Layer constants

integer(kind=iint), parameter, public :: model_dimension = 2
!****v* lattice/model_dimension
! FUNCTION
!   Store the number of dimensions of this model: 1, 2, or 3
!******
integer(kind=iint), parameter, public :: ruo2 = 0
integer(kind=iint), public :: default_layer = ruo2
!****v* lattice/default_layer
! FUNCTION
!   The layer in which the model is initially in by default (only relevant for multi-lattice models).
!******
integer(kind=iint), public :: substrate_layer = ruo2

 ! Site constants

real(kind=rsingle), dimension(3,3), public :: unit_cell_size = 0.
!****v* lattice/unit_cell_size
! FUNCTION
!   The dimensions of the unit cell (e.g. in Angstrom) of the
!   unit cell.
!******
real(kind=rsingle), dimension(2, 3), public :: site_positions
!****v* lattice/site_positions
! FUNCTION
!   The positions of (adsorption) site in the unit cell in
!   fractional coordinates.
!******
integer(kind=iint), parameter, public :: ruo2_bridge = 1
integer(kind=iint), parameter, public :: ruo2_cus = 2

integer(kind=iint), parameter, public :: spuck = 2
!****v* lattice/spuck
! FUNCTION
!   spuck = Sites Per Unit Cell Konstant
!   The number of sites per unit cell, i.e. for coordinate
!   notation (x, y, n) this is the maximum value of `n`.
!******
 ! lookup tables
integer(kind=iint), dimension(:, :), allocatable, public :: nr2lattice
!****v* lattice/nr2lattice
! FUNCTION
!   Caching array holding the mapping from index to lattice
!   coordinate: i -> (x, y, z, n).
!******
integer(kind=iint), dimension(:,:,:,:), allocatable, public :: lattice2nr
!****v* lattice/lattice2nr
! FUNCTION
!   Caching array holding the mapping from index to lattice
!   coordinate:  (x, y, z, n) -> i.
!******



contains

pure function calculate_lattice2nr(site)

!****f* lattice/calculate_lattice2nr
! FUNCTION
!    Maps all lattice coordinates onto a continuous
!    set of integer :math:`\in [1,volume]`
!
! ARGUMENTS
!
!    - ``site`` integer array of size (4) a lattice coordinate
!******
    integer(kind=iint), dimension(4), intent(in) :: site
    integer(kind=iint) :: calculate_lattice2nr

    ! site = (x,y,z,local_index)
    calculate_lattice2nr = spuck*(&
      modulo(site(1), system_size(1))&
      + system_size(1)*modulo(site(2), system_size(2)))&
      + site(4)

end function calculate_lattice2nr

pure function calculate_nr2lattice(nr)

!****f* lattice/calculate_nr2lattice
! FUNCTION
!    Maps a continuous set of
!    of integers :math:`\in [1,volume]` to a
!    4-tuple representing a lattice coordinate
!
! ARGUMENTS
!
!    - ``nr`` integer representing the site index
!******
    integer(kind=iint), intent(in) :: nr
    integer(kind=iint), dimension(4) :: calculate_nr2lattice

    calculate_nr2lattice(3) = 0
    calculate_nr2lattice(2) = (nr -1) / (system_size(1)*spuck)
    calculate_nr2lattice(1) = (nr - 1 - spuck*system_size(1)*calculate_nr2lattice(2)) / spuck
    calculate_nr2lattice(4) = nr - spuck*(system_size(1)*calculate_nr2lattice(2) + calculate_nr2lattice(1))

end function calculate_nr2lattice

subroutine allocate_system(nr_of_proc, input_system_size, system_name)

!****f* lattice/allocate_system
! FUNCTION
!    Allocates system, fills mapping cache, and
!    checks whether mapping is consistent
!
! ARGUMENTS
!
!    ``none``
!******
    integer(kind=iint), intent(in) :: nr_of_proc
    integer(kind=iint), dimension(2), intent(in) :: input_system_size
    character(len=200), intent(in) :: system_name

    integer(kind=iint) :: i, j, k, nr
    integer(kind=iint) :: check_nr
    integer(kind=iint) :: volume

    ! Copy to module wide variable
    system_size = (/input_system_size(1), input_system_size(2), 1/)
    volume = system_size(1)*system_size(2)*system_size(3)*spuck
    ! Let's check if the works correctly, first
    ! and if so populate lookup tables
    do k = 0, system_size(3)-1
        do j = 0, system_size(2)-1
            do i = 0, system_size(1)-1
                do nr = 1, spuck
                    if(.not.all((/i,j,k,nr/).eq. &
                    calculate_nr2lattice(calculate_lattice2nr((/i,j,k,nr/)))))then
                        print *,"Error in Mapping:"
                        print *, (/i,j,k,nr/), "was mapped on", calculate_lattice2nr((/i,j,k,nr/))
                        print *, "but that was mapped on", calculate_nr2lattice(calculate_lattice2nr((/i,j,k,nr/)))
                        stop
                    endif
                end do
            end do
        end do
    end do

    do check_nr=1, product(system_size)*spuck
        if(.not.check_nr.eq.calculate_lattice2nr(calculate_nr2lattice(check_nr)))then
            print *, "ERROR in Mapping:", check_nr
            print *, "was mapped on", calculate_nr2lattice(check_nr)
            print *, "but that was mapped on",calculate_lattice2nr(calculate_nr2lattice(check_nr))
            stop
        endif
    end do

    allocate(nr2lattice(1:product(system_size)*spuck,4))
    allocate(lattice2nr(-system_size(1):2*system_size(1)-1, &
        -system_size(2):2*system_size(2)-1, &
        -system_size(3):2*system_size(3)-1, &
         1:spuck))
    do check_nr=1, product(system_size)*spuck
        nr2lattice(check_nr, :) = calculate_nr2lattice(check_nr)
    end do
    do k = -system_size(3), 2*system_size(3)-1
        do j = -system_size(2), 2*system_size(2)-1
            do i = -system_size(1), 2*system_size(1)-1
                do nr = 1, spuck
                    lattice2nr(i, j, k, nr) = calculate_lattice2nr((/i, j, k, nr/))
                end do
            end do
        end do
    end do

    call base_allocate_system(nr_of_proc, volume, system_name)

    unit_cell_size(1, 1) = 6.39
    unit_cell_size(1, 2) = 0.0
    unit_cell_size(1, 3) = 0.0
    unit_cell_size(2, 1) = 0.0
    unit_cell_size(2, 2) = 3.116
    unit_cell_size(2, 3) = 0.0
    unit_cell_size(3, 1) = 0.0
    unit_cell_size(3, 2) = 0.0
    unit_cell_size(3, 3) = 20.0
    site_positions(1,:) = (/0.0, 0.5, 0.7/)
    site_positions(2,:) = (/0.5, 0.5, 0.7/)
end subroutine allocate_system

subroutine deallocate_system()

!****f* lattice/deallocate_system
! FUNCTION
!    Deallocates system including mapping cache.
!
! ARGUMENTS
!
!    ``none``
!******
    deallocate(lattice2nr)
    deallocate(nr2lattice)
    call base_deallocate_system()

end subroutine deallocate_system

subroutine add_proc(proc, site)

    integer(kind=iint), intent(in) :: proc
    integer(kind=iint), dimension(4), intent(in) :: site

    integer(kind=iint) :: nr

    nr = lattice2nr(site(1), site(2), site(3), site(4))
    call base_add_proc(proc, nr)

end subroutine add_proc

subroutine del_proc(proc, site)

    integer(kind=iint), intent(in) :: proc
    integer(kind=iint), dimension(4), intent(in) :: site

    integer(kind=iint) :: nr

    nr = lattice2nr(site(1), site(2), site(3), site(4))
    call base_del_proc(proc, nr)

end subroutine del_proc

pure function can_do(proc, site)

    logical :: can_do
    integer(kind=iint), intent(in) :: proc
    integer(kind=iint), dimension(4), intent(in) :: site

    integer(kind=iint) :: nr

    nr = lattice2nr(site(1), site(2), site(3), site(4))
    can_do = base_can_do(proc, nr)

end function can_do

subroutine replace_species(site,  old_species, new_species)

    integer(kind=iint), dimension(4), intent(in) ::site
    integer(kind=iint), intent(in) :: old_species, new_species

    integer(kind=iint) :: nr

    nr = lattice2nr(site(1), site(2), site(3), site(4))
    call base_replace_species(nr, old_species, new_species)

end subroutine replace_species

pure function get_species(site)

    integer(kind=iint) :: get_species
    integer(kind=iint), dimension(4), intent(in) :: site
    integer(kind=iint) :: nr

    nr = lattice2nr(site(1), site(2), site(3), site(4))
    get_species = base_get_species(nr)

end function get_species

subroutine reset_site(site, old_species)

    integer(kind=iint), dimension(4), intent(in) :: site
    integer(kind=iint), intent(in) :: old_species

    integer(kind=iint) :: nr

    nr = lattice2nr(site(1), site(2), site(3), site(4))
    call base_reset_site(nr, old_species)

end subroutine reset_site

end module lattice
