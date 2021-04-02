module nli_0024
use kind_values
use lattice
use proclist_constants
implicit none
contains
pure function nli_m_COdes_b3(cell)
    integer(kind=iint), dimension(4), intent(in) :: cell
    integer(kind=iint) :: nli_m_COdes_b3

    select case(get_species(cell + (/0, 0, 0, Pd100_b3/)))
      case default
        nli_m_COdes_b3 = 0; return
      case(CO)
        nli_m_COdes_b3 = m_COdes_b3; return
    end select

end function nli_m_COdes_b3

end module
