module nli_0020
use kind_values
use lattice
use proclist_constants
implicit none
contains
pure function nli_oxygen_diffusion_bridge_bridge_down(cell)
    integer(kind=iint), dimension(4), intent(in) :: cell
    integer(kind=iint) :: nli_oxygen_diffusion_bridge_bridge_down

    select case(get_species(cell + (/0, -1, 0, ruo2_bridge/)))
      case default
        nli_oxygen_diffusion_bridge_bridge_down = 0; return
      case(empty)
        select case(get_species(cell + (/0, 0, 0, ruo2_bridge/)))
          case default
            nli_oxygen_diffusion_bridge_bridge_down = 0; return
          case(oxygen)
            nli_oxygen_diffusion_bridge_bridge_down = oxygen_diffusion_bridge_bridge_down; return
        end select
    end select

end function nli_oxygen_diffusion_bridge_bridge_down

end module
