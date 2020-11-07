module nli_0036
use kind_values
use lattice
use proclist_constants
implicit none
contains
pure function nli_o_COdes_bridge2(cell)
    integer(kind=iint), dimension(4), intent(in) :: cell
    integer(kind=iint) :: nli_o_COdes_bridge2

    select case(get_species(cell + (/0, 0, 0, PdO_bridge2/)))
      case default
        nli_o_COdes_bridge2 = 0; return
      case(CO)
        nli_o_COdes_bridge2 = o_COdes_bridge2; return
    end select

end function nli_o_COdes_bridge2

end module
